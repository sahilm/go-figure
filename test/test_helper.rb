require 'simplecov'
SimpleCov.start do
  add_filter "/bundle/"
end

require 'test/unit'
require 'go_figure/test'

require 'go_figure'

