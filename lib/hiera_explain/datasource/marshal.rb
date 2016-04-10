class HieraExplain::Datasource

  # marshall is a data serialization format for Ruby. There does not exist
  # a Hiera backend for using it, nor should there be as it's a binary format.
  # But if there were, this would make hiera_explain understand it.
  def self.marshall(path)
    Marshal::load(File.read(path))
  end

end
