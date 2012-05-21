# encoding: UTF-8

Gem::Specification.new do |s|
  s.name               = "estem"
  s.version            = "0.2.1"
  s.default_executable = "es_stem"

  s.author             = "Manuel A. Güílamo"
  s.date               = "2012-05-20"
  s.description        = "Spanish stemming. Based on Martin Porter's specifications."
  s.email              = "maguilamo.c@gmail.com"
  s.files              = ["Rakefile", "bin/es_stem.rb"] + Dir["lib/**/*"]
  s.test_files         = Dir['test/*']
  s.homepage           = "https://github.com/MaG21/estem"
  s.require_paths      = ["lib"]
  s.summary            = "Spanish stemming. Based on Martin Porter's specifications."
end
 
