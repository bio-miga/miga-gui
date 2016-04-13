$:.unshift File.expand_path("../lib", __FILE__)

require "miga/gui/version"

Gem::Specification.new do |s|
  # Basic information
  s.name	= "miga-gui"
  s.version	= MiGA_GUI::VERSION
  s.date	= MiGA_GUI::VERSION_DATE.to_s
  
  # Metadata
  s.license	= "Artistic-2.0"
  s.summary	= "MiGA GUI"
  s.description = "Graphical User Interface for the Microbial Genomes Atlas"
  s.authors	= ["Luis M. Rodriguez-R"]
  s.email	= "lmrodriguezr@gmail.com"
  s.homepage	= "http://enve-omics.ce.gatech.edu/miga"
  
  # Files
  s.files = Dir[
    "../lib/**/*.rb", "../test/**/*.rb", "img/*", "bin/*",
    "Gemfile", "../Rakefile", "../README.md", "../LICENSE"
  ]
  s.executables	<< "miga"
  
  # Dependencies
  s.add_runtime_dependency "shoes", "4.0.0.pre5"
  s.add_runtime_dependency "miga-base", MiGA_GUI::MIGA_VERSION
  s.required_ruby_version = ">= 1.9"

  # Docs + tests
  s.add_development_dependency "bundler", "~> 1.10"
  s.add_development_dependency "rake", "~> 11"
  s.add_development_dependency "test-unit", "~> 3"

end
