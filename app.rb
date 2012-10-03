require 'sinatra'
require './timetabler'

configure do 
  set :sort_options, {'days' => 'Least days at uni',
                      'hours' => 'Least hours at uni',
                      'start_time' => 'Latest start time',
                      'end_time' => 'Earliest end time'}
end

helpers do
  def get_params
    @timetables = []
    @input_courses = params[:courses]
    @clash = params[:clash]
    @sort_by = params[:sort_by]
    @sort_options = settings.sort_options
  end
end

get '/' do
  @title = "Octangles"
  get_params

  erb :index
end

post '/' do
  @title = "Octangles"
  get_params

  courses = @input_courses.split(',').map{|x| Course.new(x.strip)}
  @timetables = Timetabler::generate(courses, :clash => @clash.to_i,
                                              :sort_by => params[:sort_by])
  erb :index
end
