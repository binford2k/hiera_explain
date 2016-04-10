class HieraExplain

  def self.load_datasource(backend, path)
    return {} unless File.exists? path

    begin
      require "hiera_explain/datasource/#{backend}"
    rescue LoadError => e
    end

    begin
      return HieraExplain::Datasource.send(backend.to_s, path)
    rescue => e
      puts "The #{backend} backend has a malformed datasource at #{path}"
      data = {}
    end

    data
  end
end
