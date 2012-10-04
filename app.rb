require 'sinatra'
require 'json'
require './timetabler'

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
    @force_course = params[:force_course]
    @force_course_time = params[:force_course_time]
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

  course_names = @input_courses.split(',').map{|x| x.strip.upcase}.uniq
  courses = course_names.map{|x| Course.new(x)}

  timetables = Timetabler::generate(courses, :clash => @clash.to_i,
                                              :sort_by => @sort_by_ordered,
                                              :force_course => [@force_course,
                                                                @force_course_time])

  {:timetables => timetables, :courses => course_names}.to_json
end
