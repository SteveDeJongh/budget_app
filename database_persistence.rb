# database_persistence.rb

require 'pg'

class Databasepersistence
  def initialize
    @db = PG.connect(dbname: "expenses")
  end

  def disconnect
    @db.close
  end
end