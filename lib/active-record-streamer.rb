class ActiveRecordStreamer
  def initialize(args = {})
    @args = args
  end

  def each
    sql = @args[:query].to_sql

    connection = ActiveRecord::Base.connection

    puts "Connection: #{connection.class.name}"
  end
end
