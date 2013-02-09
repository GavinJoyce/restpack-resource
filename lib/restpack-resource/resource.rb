%w{pageable filterable sortable includable}.each {|m| require "restpack-resource/resource/#{m}" }

module RESTpack
    module Resource
    class InvalidInclude < Exception; end
    class InvalidFilter < Exception; end
    class InvalidSortBy < Exception; end
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RESTpack::Resource::Pageable)
      base.extend(RESTpack::Resource::Filterable)
      base.extend(RESTpack::Resource::Sortable)
      base.extend(RESTpack::Resource::Includable)
      super
    end
    
    def to_api(options = {})
      self
    end

    module ClassMethods
      def resource_single_resource(options = {})
        
      end
    end
  end
end