require './course'

module Timetabler
  MAX_TIMETABLES = 2000

  # A timetable is an array of Activities
  class Timetable < Array
    def to_html
      timetable = []

      days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']
      result = "<table class=\"table table-bordered timetable\">\n"
      start = self.earliest_start_time
      finish = self.latest_end_time

      (start..finish).each do |h|
        timetable[h] = []
      end
      
      self.each do |a|
        a.times.each do |t|
          (t[1]..(t[2]-1)).each do |h|
            timetable[h][t[0]] ||= ""
            timetable[h][t[0]] += "+ " if timetable[h][t[0]] != ""
            timetable[h][t[0]] += "#{a.course} #{a.name} "
          end
        end
      end

      result += "<tr><th class=\"hour\">Hour</th>"
      result += days.map{|x| "<th>"+x+"</th>"}.join('') + "</tr>\n"

      (start..finish).each do |h|
        result += "<tr>"
        result += "<td class=\"hour\">" + "#{h}:00" + "</td>"

        (0..4).each do |d|
          next if timetable[h][d] == ' '
          rowspan = 1
          
          (h+1..finish).each do |r|
            if timetable[h][d] != timetable[r][d]
              break
            end

            timetable[r][d] = ' '
            rowspan += 1
          end if timetable[h][d]

          # TODO make neater

         if timetable[h][d] 
           if timetable[h][d].include?(' + ')
             cls = "clash"
           else
             cls = "class"
           end
         else
           cls = ''
         end
          
          if rowspan > 1
            result += "<td rowspan=\"#{rowspan}\" class=\"#{cls}\">"
          else
            result += "<td class=\"#{cls}\">"
          end

          if timetable[h][d]
            result += timetable[h][d]
          end

          result += "</td>"
        end
    
        result += "</tr>\n"
      end
      
      result += "</table>\n"
    end

    def to_s
      to_html
    end

    def earliest_start_time
      earliest = 24
      self.each do |a|
        a.times.each do |t|
          earliest = [earliest, t[1]].min
        end
      end

      return earliest
    end

    def latest_end_time
      latest = 6

      self.each do |a|
        a.times.each do |t|
          latest = [latest, t[2]].max
        end
      end

      return latest
    end

    def hours_at_uni
      hours = 0
      start_times = [24]*5
      end_times = [0]*5

      # find the start/end times for each day
      self.each do |a|
        a.times.each do |t|
          if t[1] < start_times[t[0]]
            start_times[t[0]] = t[1]
          end

          if t[2] > end_times[t[0]]
            end_times[t[0]] = t[2]
          end
        end
      end

      (0..4).each do |i|
        if start_times[i] != 24
          hours += end_times[i]-start_times[i]
        end
      end

      return hours
    end

    def days_at_uni
      days = 0
      seen = {}
      self.each do |a|
        a.times.each do |t|
          if not seen.has_key?(t[0]) 
            seen[t[0]] = 1
            days += 1
          end
        end
      end

      return days
    end
  end

  def Timetabler.generate(courses=[], options={})
    timetables = [] 
    required = []

    # required is an array of activity sections
    courses.each do |c|
      required += c.activities.values
    end

    options[:clash] ||= 0

    @@num_generated = 0
    generateAux(required, 0, Timetable.new, options[:clash]) do |t|
      timetables << t.clone
    end

    if options[:sort_by]
      case options[:sort_by]
      when 'days' then timetables.sort!{|x,y| x.days_at_uni <=> 
                                               y.days_at_uni}
      when 'hours' then timetables.sort!{|x,y| x.hours_at_uni <=>
                                                y.hours_at_uni} 
      when 'start_time' then timetables.sort!{|x,y| y.earliest_start_time <=> 
                                                      x.earliest_start_time}
      when 'end_time' then timetables.sort!{|x,y| x.latest_end_time <=> 
                                                    y.latest_end_time}
      end
    end
  
    return timetables
  end

  private 
  def Timetabler.generateAux(activities, index, timetable, clash=0, &block)
    if @@num_generated >= MAX_TIMETABLES
      return
    end

    if index >= activities.size
      @@num_generated += 1
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
