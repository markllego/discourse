# frozen_string_literal: true
require "pg"
require "yaml"

class TimestampsUpdater
  def initialize
    @raw_connection = PG.connect(
      host: 'localhost',
      port: 5432,
      dbname: 'timestamps_moving_testing',
      user: 'postgres',
      password: '')
  end

  def update
    puts "starting..."
    columns = all_columns_of_type("timestamp with time zone")
    columns.map do |row|
      puts row.class
      puts row
    end
    update_timestamps("table1", "column_1", 1440)
    puts "done"
  end

  def self.update
    TimestampsUpdater.new.update
  end

  private

  def all_columns_of_type(data_type)
    table_schema = 'public'
    sql = <<~SQL
      SELECT column_name, table_name
      FROM information_schema.columns
      WHERE table_schema = '#{table_schema}'
        AND data_type = '#{data_type}'
    SQL
    @raw_connection.exec(sql)
  end

  def update_timestamps(table_name, column_name, minutes)
    sql = <<~SQL
      UPDATE #{table_name}
      SET #{column_name} = #{column_name} - INTERVAL '#{minutes} minute'
    SQL
    @raw_connection.exec(sql)
  end
end

TimestampsUpdater.update
