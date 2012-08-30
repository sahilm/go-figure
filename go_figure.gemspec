# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "go_figure/version"

Gem::Specification.new do |s|
  s.name        = "go_figure"
  s.version     = GoFigure::Version::VERSION
  s.authors     = ["Nikhil Mungel", "Ketan Padegaonkar", "Shishir Das"]
  s.email       = ["hyfather@gmail.com", "KetanPadegaonkar@gmail.com", "shishir.das@gmail.com"]
  s.homepage    = "https://github.com/ThoughtWorksInc/go-figure"
  s.summary     = %q{A Ruby DSL to write a configuration file for the a go server.}
  s.description = %q{This provides a ruby DSL to create a configuration file for the go server (thoughtworks-studios.com/go)}

  s.rubyforge_project = "go_figure"

  s.files         = `git ls-files`.split($\) - Dir["**/*.gem"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rake"
  s.add_development_dependency 'test-unit'

  s.add_runtime_dependency "nokogiri"
end
