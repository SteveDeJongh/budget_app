# database_persistence.rb

require 'pg'
require 'pry'

class Databasepersistence
  def initialize
    @db = PG.connect(dbname: "expenses")
  end

  def disconnect
    @db.close
  end

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def all_expenses
    sql = <<~SQL
      SELECT * FROM expenses;
    SQL

    result = query(sql)

    result.map do |tuple|
      tuple_to_expense_hash(tuple)
    end
  end

  def addexpense(payee, category, craeted_on, amount)
    sql = <<~SQL
      INSERT INTO expenses (payee, category, created_on, amount)
      VALUES ($1, $2, $3, $4);
    SQL
    
    query(sql, payee, category, craeted_on, amount)
  end

  def tuple_to_expense_hash(tuple)
    { id: tuple["id"].to_i,
      payee: tuple["payee"],
      category: tuple["category"],
      date: tuple["created_on"],
      amount: tuple["amount"] }
  end


end