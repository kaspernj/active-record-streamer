require 'baza'

class ActiveRecordStreamer
  def initialize(args = {})
    @args = args
    @klass = args[:query].klass
    @sql = @args[:query].to_sql
    @includes = @args[:query].includes_values
  end

  def each(&blk)
    @baza_db = Baza::Cloner.from_active_record_connection(@klass.connection)

    begin
      cache = []

      @baza_db.query_ubuf(@sql) do |data|
        model = @klass.new
        model.instance_variable_set(:@new_record, false)
        model.instance_variable_set(:@attributes, data.stringify_keys!)

        cache << model

        if cache.length >= 1000
          yield_cache(cache, &blk)
          cache = []
        end
      end

      yield_cache(cache, &blk) if cache.any?
    ensure
      @baza_db.destroy
    end
  end

private

  def yield_cache(cache)
    ActiveRecord::Associations::Preloader.new(cache, @includes).run

    cache.each do |model|
      yield model
    end
  end
end
