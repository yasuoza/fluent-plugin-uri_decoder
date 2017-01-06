require 'bundler'
require 'bundler/setup'
require 'fluent/test'
require 'fluent/test/helpers'
require 'fluent/test/driver/output'
require 'test-unit'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
