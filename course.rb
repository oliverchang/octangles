require 'open-uri'
require 'nokogiri'

class Activity
  attr_reader :course
  attr_reader :name
  attr_reader :times

  def initialize(course, name)
    @course = course
    @name = name
    @times = []
  end

  def add_time(day, start, finish)
    if not @times.include?([day, start, finish])
      @times << [day, start, finish] 
    end
  end

  def to_s 
    "#{@course} #{@name} #{@times.to_s}"
  end

  def to_json(*a)
    {"#{course} #{name}" => @times}.to_json(*a)
  end
end

class Course 
  attr_reader :name
  attr_reader :activities

  TIMETABLE_URI = 'http://www.timetable.unsw.edu.au/current/'
  TEACHING_PERIOD = 'Teaching Period One'
  NON_HOUR_START = "Octangles currently does not take into account classes that don't start on the hour. You may get suboptimal timetables as these times are rounded."

  def initialize(name, warnings=[])
    @name = name.upcase

    # activities is a Hash where the keys 
    # are the class types (e.g. Lecture) and the values
    # are the different timeslots
    @activities = get_activities warnings
  end
  
  private 
  def get_activities(warnings=[])
    activities = {}
    begin
      doc = Nokogiri::HTML(open(TIMETABLE_URI+@name+'.html')) 
    rescue
      return {}
    end

    doc.css('td.sectionSubHeading').each do |period|
      if period.content == TEACHING_PERIOD
        data = period.parent.parent.next_sibling.next_sibling
        data.css('tr.rowHighlight', 'tr.rowLowlight').each do |row|
          info = row.css('td.data').map{|x| x.content}

          activity = Activity.new(@name, info[0])

          # Some class times are stored on multiple lines
          info[6].gsub!(/\n/, ' ')

          # Grab the class times
          info[6].gsub(/\(.*?\)/, '').split(', ').each do |t|
            # Times are in the format "Mon 09:00 - 10:00"
            t =~ /^\s*(\w+)\s+(\d{2}):(\d{2})\s+-\s+(\d{2}):(\d{2}).*/
            start = $2.to_i
            finish = $4.to_i

            if $3.to_i != 0 or $5.to_i != 0 
              finish += 1 if $5.to_i != 0
              # does not handle half hour starts/ends etc
              warnings << NON_HOUR_START if not warnings.include?(NON_HOUR_START)
            end

            activity.add_time day_to_index($1), start, finish
          end

          activities[activity.name] ||= []
          activities[activity.name] << activity
        end
      end
    end
    
    # Make sure the activity times are unique
    activities.values.each do |a|
      a.uniq!{|x| x.times}
    end

    return activities
  end

  def day_to_index(day)
    indexes = {'Mon' => 0,
               'Tue' => 1,
               'Wed' => 2,
               'Thu' => 3,
               'Fri' => 4,
               'Sat' => 5,
               'Sun' => 6}

    indexes[day]
  end
end
