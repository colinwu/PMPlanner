# -*- encoding: utf-8 -*-
# stub: css3-progress-bar-rails 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "css3-progress-bar-rails"
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Nicholas Fine", "Josh Sullivan"]
  s.date = "2013-09-23"
  s.description = "Integrates Josh Sullivan's CSS3 Progress Bars into Rails and adds ActionView helpers for generation."
  s.email = ["nicholas.fine@gmail.com", "josh@dipperstove.com"]
  s.homepage = "http://ndfine.com/2012/01/03/css3-progress-bars-for-rails.html"
  s.rubyforge_project = "css3-progress-bar-rails"
  s.rubygems_version = "2.4.8"
  s.summary = "Integrates Josh Sullivan's CSS3 Progress Bars into Rails 3.1+ Projects."

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 3.1"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 3.1"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 3.1"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
