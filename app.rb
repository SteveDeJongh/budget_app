# app.rb Budget App #

require 'sinatra'
require 'tilt/erubis'
require 'pry'

configure do
  enable :sessions
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload 'database_persistence.rb'
end

require_relative "database_persistence"
require_relative "expense"

before do
  @storage = Databasepersistence.new
end

after do
  @storage.disconnect
end

get '/' do
  @expenses = @storage.all_expenses
  erb :home, layout: :layout
end

post '/addexpense' do
  @data = [params[:payee].strip, params[:category].strip, params[:date].strip, params[:amount].strip]
  @storage.addexpense(@data[0], @data[1], @data[2], @data[3])
  session[:success] = 'Transaction has been added.'
  redirect '/'  
end

get '/expenses' do
  @expenses = @storage.all_expenses
  erb :expenses, layout: :layout
end

get '/addexpense' do
  erb :addexpense, layout: :layout
end