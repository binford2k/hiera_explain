class HieraExplain::Datasource

  def self.yaml(path)
    require 'yaml'
    YAML.load_file(path)
  end

  def self.json(path)
    require 'json'
    JSON.parse(File.read(path))
  end

  def self.eyaml(path)
    require 'yaml'
    data = YAML.load_file(path)
    data.each do |key, value|
      data[key] = '<<encrypted>>' if data =~ /.*ENC\[.*?\]/
    end
    data
  end

end
