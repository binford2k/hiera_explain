require 'rubygems'

class HieraExplain::Scope
  attr_accessor :scope

  def initialize()
    @scope = {}
  end

  def empty?
    @scope.empty?
  end

  def include?(key)
    @scope.include?(key)
  end

  def [](key)
    @scope[key]
  end

  def []=(key, value)
    @scope[key] = value
  end

  # Loads the scope from YAML or JSON files
  def load_scope(source, type=:yaml)
    case type
    when :mcollective
      begin
        require 'mcollective'

        util = MCollective::RPC::Client.new('rpcutil',
                  :configfile => MCollective::Util.config_file_for_user,
                  :options    => MCollective::Util.default_options,
               )
        util.progress = false
        nodestats = util.custom_request("inventory", {}, source, {"identity" => source}).first

        raise "Failed to retrieve facts for node #{source}: #{nodestats[:statusmsg]}" unless nodestats[:statuscode] == 0

        scope = nodestats[:data][:facts]
      rescue Exception => e
        STDERR.puts "MCollective lookup failed: #{e.class}: #{e}"
        exit 1
      end

    when :yaml
      raise "Cannot find scope #{type} file #{source}" unless File.exist?(source)

      require 'yaml'

      # Attempt to load puppet in case we're going to be fed
      # Puppet yaml files
      begin
          require 'puppet'
      rescue
      end

      scope = YAML.load_file(source)

    when :json
      raise "Cannot find scope #{type} file #{source}" unless File.exist?(source)

      require 'json'

      scope = JSON.load(File.read(source))

    when :puppetdb
      require 'puppet'
      begin
        Puppet.initialize_settings unless Puppet.settings.global_defaults_initialized?
        Puppet::Node::Facts.indirection.terminus_class = :puppetdb
        scope = YAML.load(Puppet::Node::Facts.indirection.find(source).to_yaml)
      rescue Exception => e
          STDERR.puts "PuppetDB fact lookup failed: #{e.class}: #{e}"
          exit 1
      end

    when :inventory_service
      # For this to work the machine running the hiera command needs access to
      # /facts REST endpoint on your inventory server.  This access is
      # controlled in auth.conf and identification is by the certname of the
      # machine running hiera commands.
      #
      # Another caveat is that if your inventory server isn't at the short dns
      # name of 'puppet' you will need to set the inventory_sever option in
      # your puppet.conf.  Set it in either the master or main sections.  It
      # is fine to have the inventory_server option set even if the config
      # doesn't have the fact_terminus set to rest.
      begin
        require 'puppet/util/run_mode'
        $puppet_application_mode = Puppet::Util::RunMode[:master]
#         require 'puppet'
#         Puppet.settings.parse
        Puppet::Node::Facts.indirection.terminus_class = :rest
        scope = YAML.load(Puppet::Node::Facts.indirection.find(source).to_yaml)
        # Puppet makes dumb yaml files that do not promote data reuse.
        scope = scope.values if scope.is_a?(Puppet::Node::Facts)
      rescue Exception => e
          STDERR.puts "Puppet inventory service lookup failed: #{e.class}: #{e}"
        puts e.backtrace
          exit 1
      end
    else
      raise "Don't know how to load data type #{type}"
    end

    # Puppet makes dumb yaml files that do not promote data reuse.
    scope = scope.values if scope.is_a?(Puppet::Node::Facts)
    raise "Scope from #{type} file #{source} should be a Hash" unless scope.is_a?(Hash)

    @scope.merge! scope
  end

end