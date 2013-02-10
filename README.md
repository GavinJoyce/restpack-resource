# restpack-resource [![Build Status](https://api.travis-ci.org/RestPack/restpack-resource.png?branch=master)](https://travis-ci.org/RestPack/restpack-resource) [![Code Climate](https://codeclimate.com/github/RESTpack/restpack-resource.png)](https://codeclimate.com/github/RESTpack/restpack-resource) [![Dependency Status](https://gemnasium.com/RestPack/restpack-resource.png)](https://gemnasium.com/RestPack/restpack-resource)

RESTful resource paging, side-loading, filtering and sorting. 

Define your models:

```ruby
class Channel
  include DataMapper::Resource
  include RestPack::Resource
  property :id, Serial
  property :name, String, :length => 512
  timestamps :at
  
  validates_presence_of :name
  
  has n, :applications
  has n, :domains
  has n, :configurations
  
  resource_can_include :applications, :domains, :configurations
  resource_can_filter_by :id
  resource_can_sort_by :id, :created_at, :modified_at
  
  def as_resource
    {
      :id => id,
      :name => name,
      :url => "/api/v1/channels/#{id}.json"
    }
  end
end
```

Then you can do this in your API (Grape in this example):

```ruby
module ChannelAPI
  class V1 < Grape::API
    version 'v1', :using => :path, :format => :json

    resource :channels do
      get do        
        Channel.paged_resource(params)
      end
    end
  end
end
```

Which gives you endpoints such as:

`/api/v1/channels.json?includes=applications,domains,configurations`

```javascript
{
    "page": 1,
    "page_count": 1,
    "count": 2,
    "previous_page": null,
    "next_page": null,
    "channels": [
        {
            "id": 1,
            "name": "Developer Jobs Websites",
            "url": "/api/v1/channels/1.json"
        },
        {
            "id": 2,
            "name": "Coffee Roulette",
            "url": "/api/v1/channels/2.json"
        }
    ],
    "application_count": 3,
    "applications": [
        {
            "id": 3,
            "name": "Coffee Roulette Application",
            "channel_id": 2,
            "url": "/api/v1/applications/3.json"
        },
        {
            "id": 2,
            "name": "Python Jobs",
            "channel_id": 1,
            "url": "/api/v1/applications/2.json"
        },
        {
            "id": 1,
            "name": "Ruby Jobs",
            "channel_id": 1,
            "url": "/api/v1/applications/1.json"
        }
    ],
    "domain_count": 5,
    "domains": [
        {
            "id": 5,
            "identifier": "www.coffeeroulette.ie",
            "channel_id": 2,
            "application_id": 3,
            "url": "/api/v1/domain/5.json"
        },
        {
            "id": 4,
            "identifier": "account.pythonjobs.ie",
            "channel_id": 1,
            "application_id": 2,
            "url": "/api/v1/domain/4.json"
        },
        {
            "id": 3,
            "identifier": "www.pythonjobs.ie",
            "channel_id": 1,
            "application_id": 2,
            "url": "/api/v1/domain/3.json"
        },
        {
            "id": 2,
            "identifier": "account.rubyjobs.ie",
            "channel_id": 1,
            "application_id": 1,
            "url": "/api/v1/domain/2.json"
        },
        {
            "id": 1,
            "identifier": "www.rubyjobs.ie",
            "channel_id": 1,
            "application_id": 1,
            "url": "/api/v1/domain/1.json"
        }
    ],
    "configuration_count": 2,
    "configurations": [
        {
            "id": 11,
            "name": "channel_key",
            "value": {
                "aaa": "111",
                "bbb": "222"
            },
            "channel_id": 2,
            "application_id": null,
            "domain_id": null,
            "url": "/api/v1/configuration/11.json"
        },
        {
            "id": 10,
            "name": "Key",
            "value": {
                "description": "Channel Config"
            },
            "channel_id": 2,
            "application_id": null,
            "domain_id": null,
            "url": "/api/v1/configuration/10.json"
        }
    ]
}
```

