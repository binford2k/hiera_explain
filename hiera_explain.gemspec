$:.unshift File.expand_path("../lib", __FILE__)
require 'date'

Gem::Specification.new do |s|
  s.name              = "hiera_explain"
  s.version           = '0.0.2'
  s.date              = Date.today.to_s
  s.summary           = "Provides an explanation of how Hiera retrieves data."
  s.homepage          = "https://github.com/binford2k/hiera_explain"
  s.license           = 'Apache 2.0'
  s.email             = "binford2k@gmail.com"
  s.authors           = ["Ben Ford"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( hiera_explain )

  s.files             = %w( README.md LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("doc/**/*")

  s.add_dependency      "puppet"
  s.add_dependency      "hiera"
  s.add_dependency      "colorize"

  s.description       = <<-desc
  Hiera lookups have always been hard for people to understand. This tool will
  display the entire lookup hierarchy, including filenames, exactly as Hiera will
  interpret them and in the order that Hiera will resolve them.

  Then it will display all the data which can be retrieved from Hiera, given the
  node scope being used.
  desc
end
