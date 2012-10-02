require './course.rb'

# A timetable is an array of Activities
module Timetabler
  MAX_TIMETABLES = 2000

  def Timetabler.generate(courses=[], allowed_clash=0)
    timetables = [] 
    required = []

    courses.each do |c|
      required += c.activities.values
    end

    generateAux required, 0, [], 0 do |t|
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
      if fits(timetable, a, clash)
        timetable << a
        generateAux(activities, index+1, timetable, &block)
        timetable.pop
      end
    end
  end

  def Timetabler.fits(timetable, activity, clash=0)
    timetable.each do |a|
      a.times.each do |t1|
        activity.times.each do |t2|
          if clash(t1, t2)
            return false
          end
        end
      end
    end

    return true
  end

  def Timetabler.clash(t1, t2)
    if t1[0] == t2[0]
      # if the timeslot that starts later
      # starts before the other one ends,
      # there is a clash
      if t1[1] >= t2[1] 
        if t1[1] < t2[2]
          return true
        end
      else
        if t2[1] < t1[2]
          return true
        end
      end
    end

    return false
  end
end
