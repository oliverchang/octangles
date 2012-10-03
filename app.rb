require 'sinatra'
require './timetabler'

configure do 
  set :sort_options, {'days' => 'Least days at uni',
                      'hours' => 'Least hours at uni',
                      'start_time' => 'Latest start time',
                      'end_time' => 'Earliest end time'}
end

get '/' do
  @title = "Octangles"
  @timetables = []
  @input_courses = ''
  @clash = 0
  @sort_by = ''
  @sort_options = settings.sort_options
  erb :index
end

get '/generate/:courses/:clash' do
  @title = "Octangles"
  courses = params[:courses].split(',').map{|x| Course.new(x.strip)}
  @timetables = Timetabler::generate(courses, :clash => params[:clash].to_i)
  erb :index
end

post '/generate' do
  @title = "Octangles"
  @input_courses = params[:courses]
  @sort_options = settings.sort_options
  @sort_by = params[:sort_by]
  @clash = params[:clash].to_i
  courses = params[:courses].split(',').map{|x| Course.new(x.strip)}
  @timetables = Timetabler::generate(courses, :clash => @clash,
                                              :sort_by => params[:sort_by])
  erb :index
end
