# coding: utf-8
#
# unobtainium-multiwait
# https://github.com/jfinkhaeuser/unobtainium-multiwait
#
# Copyright (c) 2016-2018 Jens Finkhaeuser and other unobtainium-multiwait contributors.
# All rights reserved.
#

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'unobtainium-multiwait/version'

# rubocop:disable Style/UnneededPercentQ, Style/ExtraSpacing
# rubocop:disable Style/SpaceAroundOperators
Gem::Specification.new do |spec|
  spec.name          = "unobtainium-multiwait"
  spec.version       = Unobtainium::MultiWait::VERSION
  spec.authors       = ["Jens Finkhaeuser"]
  spec.email         = ["jens@finkhaeuser.de"]
  spec.description   = %q(
    This gem provides a driver module for unobtainium allowing for more easily
    waiting for (one of) multiple elements to change state.

    It is based on the unobtainium-multifind gem.
  )
  spec.summary       = %q(
    This gem provides a driver module for unobtainium allowing for more easily
    waiting for (one of) multiple elements to change state.
  )
  spec.homepage      = "https://github.com/jfinkhaeuser/unobtainium-multiwait"
  spec.license       = "MITNFA"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0'

  spec.requirements  = "Unobtainium driver implementing the Selenium API"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 11.3"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "simplecov", "~> 0.16"
  spec.add_development_dependency "yard", "~> 0.9", ">= 0.9.12"
  spec.add_development_dependency "selenium-webdriver"
  spec.add_development_dependency "phantomjs"

  spec.add_dependency "unobtainium", "~> 0.13"
  spec.add_dependency "unobtainium-multifind", "~> 0.4"
end
# rubocop:enable Style/SpaceAroundOperators
# rubocop:enable Style/UnneededPercentQ, Style/ExtraSpacing
