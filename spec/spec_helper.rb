require 'rubygems'
require 'bundler'
Bundler.setup(:default, :test)

require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-migrations'
require 'dm-types'
require 'dm-serializer'
require 'dm-pager'

require './lib/restpack-resource'

ENV["RACK_ENV"] ||= 'test'

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper::Model.raise_on_save_failure = true 
DataMapper::Pagination.defaults[:per_page] = 10



RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
