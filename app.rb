require 'sinatra'
require 'json'
require './timetabler'

class Octangles < Sinatra::Base 
   configure do 
     set :sort_options, {'days' => 'Least days at uni',
                         'hours' => 'Least hours at uni',
                         'sleep_in_time' => 'Sleep in time',
                         'start_time' => 'Latest start time',
                         'end_time' => 'Earliest end time'}
   end

   helpers do
     def get_params
       @timetables = []
       @input_courses = params[:courses]
       @clash = params[:clash]
       @sort_by = params[:sort_by]
       @sort_by_ordered = params[:sort_by_ordered]
       @force_courses = params[:force_courses]
       @force_course_times = params[:force_course_times]
       @include_closed = params[:include_closed]
       @sort_options = settings.sort_options
     end
   end

   get '/' do
     @title = "Octangles"
     get_params

     erb :index
   end

   post '/generate.json' do
     content_type :json
     get_params

     courses = []
     warnings = []

     course_names = @input_courses.split(',').map{|x| x.strip.upcase}.select{|x| x != '' }.uniq

     course_names.each do |c|
       new_course = Course.new(c, warnings, :include_closed => 
                                            @include_closed)

       if new_course.activities != {}
         courses << new_course
       else
         warnings << "No classes found for #{c}"
       end
     end

     force_courses = @force_courses.split(',');
     force_course_times = @force_course_times.split(',');

     timetables = Timetabler::generate(courses, :clash => @clash.to_i,
                                                 :sort_by => @sort_by_ordered,
                                                 :force_courses => 
                                                   force_courses.zip(force_course_times))

     {:timetables => timetables, :courses => course_names, :warnings => warnings.uniq}.to_json
   end
end
