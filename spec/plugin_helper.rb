if ENV["COVERALLS"] || ENV["SIMPLECOV"]
  require "simplecov"

  if ENV["COVERALLS"]
    require "coveralls"
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    root File.expand_path("../..", __FILE__)
    add_filter "spec/"
    add_filter "db/migrate"
    add_filter "gems/"
  end
end

require "rails_helper"
