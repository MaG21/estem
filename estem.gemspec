# encoding: UTF-8

Gem::Specification.new do |s|
  s.name               = "estem"
  s.version            = "0.2.5"
  s.required_ruby_version = '>= 1.9.1'

  s.author             = "Manuel A. Güílamo"
  s.email              = "maguilamo.c@gmail.com"

  s.date               = "2012-08-02"
  s.description        = "Spanish stemming. Based on Martin Porter's specifications. See README file for more information."
  s.summary            = "Spanish stemming. Based on Martin Porter's specifications."

  s.files              = ["Rakefile"] + Dir["lib/**/*"] + Dir["examples/**/*"] +
                         ['COPYRIGHT', 'README.rdoc', 'ChangeLog']
  s.test_files         = Dir['test/*']
  s.homepage           = "https://github.com/MaG21/estem"
  s.require_paths      = ["lib"]
end
 
