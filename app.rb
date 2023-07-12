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

def expense_input_validation(data)
  message = check_payee(data[0])
  message = check_category(data[1])
  message = check_date(data[2])
  message = check_amount(data[3])

  message ? message : nil
end

def check_payee(payee)
  if !(1..100).cover?(payee.size)
    "Payee name must be between 1 and 100 characters."
  end
end

def check_category(category)
  if !(1..100).cover?(category.size)
    "Category must be between 1 and 100 characters."
  end
end

def check_date(date)
  if !date.match(/\b\d\d\d\d-\d\d-\d\d\b/)
    "Date must be written out as YYYY-MM-DD."
  end
end

def check_amount(amount)
  if amount.to_i != amount || amount.to_i > 100000
    "Amount must be a number less than 100000."
  end
end

get '/' do
  @expenses = @storage.all_expenses
  erb :home, layout: :layout
end

post '/addexpense' do
  @data = [params[:payee].strip, params[:category].strip, params[:date].strip, params[:amount].strip]
  error = expense_input_validation(@data)
  if error
    session[:error] = error
    redirect '/addexpense'
  else
    @storage.addexpense(@data[0], @data[1], @data[2], @data[3])
    session[:success] = 'Transaction has been added.'
    redirect '/' 
  end
end

get '/expenses' do
  @expenses = @storage.all_expenses
  erb :expenses, layout: :layout
end

get '/addexpense' do
  erb :addexpense, layout: :layout
end