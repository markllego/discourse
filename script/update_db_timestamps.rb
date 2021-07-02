# frozen_string_literal: true
require "pg"

def update_timestamps_sql
  <<~SQL
    UPDATE table1
    SET column_3 = column_3 - INTERVAL '1440 minute'
  SQL
end

puts "starting..."

raw_connection = PG.connect(
  host: 'localhost',
  port: 5432,
  dbname: 'timestamps_moving_testing',
  user: 'postgres',
  password: '')

sql = update_timestamps_sql
raw_connection.exec(sql)

puts "done"
