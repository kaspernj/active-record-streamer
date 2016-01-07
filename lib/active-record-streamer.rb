require "baza"

class ActiveRecordStreamer
  RAILS_4 = ActiveRecord::VERSION::STRING.start_with?("4")

  def initialize(args = {})
    @args = args
    @klass = args[:query].klass
    @sql = @args[:query].to_sql
    @includes = @args[:query].includes_values
  end

  def rails4?
    RAILS_4
  end

  def each(&blk)
    if @klass.respond_to?(:connection_without_octopus)
      @baza_db = Baza::Cloner.from_active_record_connection(@klass.connection_without_octopus)
    else
      @baza_db = Baza::Cloner.from_active_record_connection(@klass.connection)
    end

    begin
      cache = []

      @baza_db.query_ubuf(@sql) do |data|
        model = @klass.new

        if rails4?
          model.assign_attributes(data)
          model.instance_variable_set(:@new_record, false)
        else
          model.instance_variable_set(:@new_record, false)
          model.instance_variable_set(:@attributes, data.stringify_keys!)
        end

        cache << model

        if cache.length >= 1000
          yield_cache(cache, &blk)
          cache = []
        end
      end

      yield_cache(cache, &blk) if cache.any?
    ensure
      @baza_db.close
    end
  end

private

  def yield_cache(cache)
    if rails4?
      ActiveRecord::Associations::Preloader.new.preload(cache, @includes)
    else
      ActiveRecord::Associations::Preloader.new(cache, @includes).run
    end

    cache.each do |model|
      yield model
    end
  end
end
