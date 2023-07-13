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
  @sorting_categories = ['Payee', 'Category', 'Month', 'Year']
end

after do
  @storage.disconnect
end

def expense_input_validation(data)
  message = if !(1..100).cover?(data[0].size)
              "Payee name must be between 1 and 100 characters."
            elsif !(1..100).cover?(data[1].size)
              "Category must be between 1 and 100 characters."
            elsif !data[2].match(/\b\d\d\d\d-\d\d-\d\d\b/)
              "Date must be written out as YYYY-MM-DD."
            elsif data[3].to_i.to_s != data[3] || data[3].to_i > 9999.99
              "Amount must be a number less than $10,000."
            end

  message ? message : nil
end

def find_expense(id)
  expense = @storage.find_expense(id)
  return expense if expense

  session[:error] = "Expense not found."
  redirect '/'
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

get '/expense/:id' do
  @expense = find_expense(params[:id])
  erb :viewexpense, layout: :layout
end

get '/editexpense/:id' do
  @expense = find_expense(params[:id])
  erb :editexpense, layout: :layout
end

post '/editexpense/:id' do
  @data = [params[:payee].strip, params[:category].strip, params[:date].strip, params[:amount].strip, params[:id].to_i]
  error = expense_input_validation(@data)
  if error
    session[:error] = error
    redirect "/editexpense/#{params[:id]}"
  else
    @storage.editexpense(@data[0], @data[1], @data[2], @data[3], @data[4])
    session[:success] = 'Transaciton has been edited.'
    redirect "/expense/#{params[:id]}"
  end
end

get '/editexpense/:id/delete' do
  @expense = find_expense(params[:id])
  erb :delete, layout: :layout
end

post '/editexpense/:id/delete' do
  @expense = find_expense(params[:id])
  @storage.delete_expense(params[:id])
  session[:success] = "#{@expense[:payee]} has been deleted."
  redirect '/'
end

get '/viewreports' do
  @param = params[:cat]
  @data = case @param
            when "Payee" then @storage.group_expenses_by_payee
            when "Category" then @storage.group_expenses_by_category
            when "Month" then @storage.group_expenses_by_month
            when "Year" then @storage.group_expenses_by_year
          end
  erb :report, layout: :layout
end

get '/reports' do
  @data = @storage.group_by('category')
  erb :report, layout: :layout  
end

def grouping_query(param)
  case param
  when 'Payee' then 'payee'
  when 'Category' then 'category'
  when 'Month' then "TO_CHAR(created_on, 'Month')"
  when 'Year' then "EXTRACT('YEAR' FROM created_on)"
  end
end