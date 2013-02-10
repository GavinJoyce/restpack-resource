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
require 'factory_girl'

require './lib/restpack-resource'

ENV["RACK_ENV"] ||= 'test'

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper::Model.raise_on_save_failure = true 
DataMapper::Pagination.defaults[:per_page] = 10


class Artist
  include DataMapper::Resource
  include RestPack::Resource
  property :id, Serial
  property :name, String
  #timestamps :at #NOTE: GJ: FactoryGirl is not saving when DM timestamps are used
  
  validates_presence_of :name
  has n, :songs
  
  resource_can_include :songs
  resource_can_sort_by :id, :name
  
  def as_resource
    {
      id: id,
      name: name,
      url: "/api/v1/artists/#{id}"
    }
  end
end

class Song
  include DataMapper::Resource
  include RestPack::Resource
  property :id, Serial
  property :name, String
  property :artist_id, Integer
  property :created_by, Integer
  property :modified_by, Integer
  #timestamps :at

  validates_presence_of :name
  belongs_to :artist
  belongs_to :creator, 'User', :child_key  => [ :created_by ]
  belongs_to :modifier, 'User', :child_key  => [ :modified_by ]
  has n, :comments
  
  resource_can_include :artists, :users
  resource_can_filter_by :artist_id
  
  def as_resource
    {
      id: id,
      name: name,
      artist_id: artist_id,
      url: "/api/v1/songs/#{id}"
    }
  end
end

class Comment
  include DataMapper::Resource
  include RestPack::Resource
  property :id, Serial
  property :song_id, Integer
  property :text, String
  #timestamps :at
  
  validates_presence_of :text
  belongs_to :song
end

class User
  include DataMapper::Resource
  include RestPack::Resource
  property :id, Serial
  property :name, String
  #timestamps :at
  
  def as_resource
    {
      id: id,
      name: name,
      custom: "This is custom data"
    }
  end
end

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  
  config.include FactoryGirl::Syntax::Methods
  
  config.before(:each) do
    DataMapper.auto_migrate!
  end
end
