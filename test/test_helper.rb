require 'simplecov'
require 'minitest/test'
require 'minitest/autorun'
require 'rack-minitest/test'

SimpleCov.minimum_coverage 90
SimpleCov.start

require './wallet_service'
