require './course.rb'

# A timetable is an array of Activities
module Timetabler
  MAX_TIMETABLES = 2000

  def Timetabler.generate(courses=[], allowed_clash=0)
    timetables = [] 
    required = []

    # required is an array of activity sections
    courses.each do |c|
      required += c.activities.values
    end

    generateAux required, 0, [], allowed_clash do |t|
      timetables << t.clone
    end

    puts timetables.size
  end

  private 
  def Timetabler.generateAux(activities, index, timetable, clash=0, &block)
    if index >= activities.size
      block.call(timetable)
      return
    end

    activities[index].each do |a|
      f, c = fits(timetable, a, clash)
      if f
        timetable << a
        generateAux(activities, index+1, timetable, clash-c, &block)
        timetable.pop
      end
    end
  end

  # returns [true|false, number of clash hours used]
  def Timetabler.fits(timetable, activity, clash=0)
    current_clash = 0

    timetable.each do |a|
      a.times.each do |t1|
        activity.times.each do |t2|
          c = clash(t1, t2)
          if current_clash+c <= clash
            current_clash += c
          else
            return false, 0
          end
        end
      end
    end

    return true, current_clash
  end

  # returns the number of clash hours
  def Timetabler.clash(t1, t2)
    if t1[0] == t2[0]
      # if the timeslot that starts later
      # starts before the other one ends,
      # there is a clash
      # TODO: clean this shit up
      if t1[1] >= t2[1] 
        if t1[1] < t2[2]
          c = t2[2] - t1[1]
          c -= (t2[2]-t1[2]) if t1[2] < t2[2]
          return c
        end
      else
        if t2[1] < t1[2]
          c = t1[2] - t2[1]
          c -= (t1[2]-t2[2]) if t2[2] < t1[2]
          return c
        end
      end
    end

    return 0
  end
end
