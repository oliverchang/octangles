require 'sinatra'
require './timetabler'

get '/' do
  @title = "Octangles"
  @timetables = []
  @input_courses = ''
  @input_clash = ''
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
  @input_clash = params[:clash]
  courses = params[:courses].split(',').map{|x| Course.new(x.strip)}
  @timetables = Timetabler::generate(courses, :clash => params[:clash].to_i)
  erb :index
end
