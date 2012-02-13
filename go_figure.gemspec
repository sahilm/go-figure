# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "go_figure/version"

Gem::Specification.new do |s|
  s.name        = "go_figure"
  s.version     = GoFigure::VERSION
  s.authors     = ["Ketan Padegaonkar"]
  s.email       = ["KetanPadegaonkar@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Ruby DSL to write a configuration file for the a go server.}
  s.description = %q{This provides a ruby DSL to create a configuration file for the go server (thoughtworks-studios.com/go)}

  s.rubyforge_project = "go_figure"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
