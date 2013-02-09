# restpack-resource [![Build Status](https://travis-ci.org/RestPack/restpack-resource.png?branch=master)](https://travis-ci.org/RestPack/restpack-resource) [![Code Climate](https://codeclimate.com/github/RESTpack/restpack-resource.png)](https://codeclimate.com/github/RESTpack/restpack-resource) [![Dependency Status](https://gemnasium.com/RestPack/restpack-resource.png)](https://gemnasium.com/RestPack/restpack-resource)

RESTful resource paging, side-loading, filtering and sorting:

```ruby
class Group
  include DataMapper::Resource
  include RestPack::Resource

  property :id, Serial
  property :name, String, :length => 128
  property :created_by, Integer, :required => true
  property :channel_id, Integer, :required => true
  timestamps :at

  validates_presence_of :name, :channel_id
  
  has n, :invitations
  has n, :memberships
  
  resource_can_include :memberships, :invitations
  resource_can_filter_by :channel_id, :created_by
  resource_can_sort_by :id
end
```
