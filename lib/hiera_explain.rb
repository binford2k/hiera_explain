class HieraExplain

  def self.load_datasource(backend, path)
    return {} unless File.exists? path

    begin
      return HieraExplain::Datasource.send(backend.to_s, path)
    rescue => e
      puts "The #{backend} backend has a malformed datasource at #{path}"
      data = {}
    end

    data
  end

  def self.match(key, filter)
    return true if filter.nil?

    case filter
    when String
      key == filter
    when Regexp
      key =~ filter
    end
  end

end
