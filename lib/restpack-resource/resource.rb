%w{pageable filterable sortable includable}.each {|m| require "restpack-resource/resource/#{m}" }

module RestPack
    module Resource
    class InvalidInclude < Exception; end
    class InvalidFilter < Exception; end
    class InvalidSortBy < Exception; end
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Resource::Pageable)
      base.extend(RestPack::Resource::Filterable)
      base.extend(RestPack::Resource::Sortable)
      base.extend(RestPack::Resource::Includable)
      super
    end
    
    def as_resource(options = {})
      self
    end

    module ClassMethods
      def resource_single_resource(options = {})
        
      end
    end
  end
end