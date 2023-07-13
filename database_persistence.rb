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

  def addexpense(payee, category, created_on, amount)
    sql = <<~SQL
      INSERT INTO expenses (payee, category, created_on, amount)
      VALUES ($1, $2, $3, $4);
    SQL
    
    query(sql, payee, category, created_on, amount)
  end

  def find_expense(id)
    sql = <<~SQL 
      SELECT * FROM expenses
      WHERE id = $1;
    SQL

    result = query(sql, id)

    tuple_to_expense_hash(result.first)
  end

  def editexpense(payee, category, created_on, amount, id)
    sql = <<~SQL
      UPDATE expenses 
      SET payee = $1, category = $2, created_on = $3, amount = $4
      WHERE id = $5;
    SQL
    
    query(sql, payee, category, created_on, amount, id)
  end

  def tuple_to_expense_hash(tuple)
    { id: tuple["id"].to_i,
      payee: tuple["payee"],
      category: tuple["category"],
      date: tuple["created_on"],
      amount: tuple["amount"] }
  end

  def group_by(selector)
    sql = <<~SQL 
      SELECT #{selector}, sum(amount) FROM expenses
      GROUP BY #{selector}
      ORDER BY #{selector} ASC;
    SQL
    query(sql)
  end

  def categories
    sql = <<~SQL
    SELECT DISTINCT(category) FROM expenses;
    SQL

    query(sql)
  end


end