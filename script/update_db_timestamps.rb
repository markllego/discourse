# frozen_string_literal: true
require "pg"

class TimestampsUpdater
  TABLE_SCHEMA = 'public'

  def initialize
    @raw_connection = PG.connect(
      host: 'localhost',
      port: 5432,
      dbname: 'discourse_development_copy',
      user: 'postgres',
      password: '')
  end

  def update(days, backward = false)
    postgresql_date_types = [
      "timestamp without time zone",
      "timestamp with time zone",
      "date"
    ]

    postgresql_date_types.each do |data_type|
      columns = all_columns_of_type(data_type)
      columns.each do |column|
        update_timestamps column["table_name"], column["column_name"], days, backward
      end
    end
  end

  def self.update(days, backward = false)
    TimestampsUpdater.new.update days, backward
  end

  private

  def all_columns_of_type(data_type)
    sql = <<~SQL
      SELECT c.column_name, c.table_name
      FROM information_schema.columns AS c
      JOIN information_schema.tables AS t
        ON c.table_name = t.table_name
      WHERE c.table_schema = '#{TABLE_SCHEMA}'
        AND c.data_type = '#{data_type}'
        AND t.table_type = 'BASE TABLE'
    SQL
    @raw_connection.exec(sql)
  end

  def update_timestamps(table_name, column_name, days, backward = false)
    operator = backward ? "-" : "+"
    sql = <<~SQL
      UPDATE #{table_name}
      SET #{column_name} = #{column_name} #{operator} INTERVAL '#{days} day'
    SQL
    @raw_connection.exec(sql)
  end
end

days = 365
backward = false
TimestampsUpdater.update days, backward
