%w{pageable filterable sortable includable single}.each {|m| require "restpack-resource/resource/#{m}" }

module RestPack
    module Resource
    class InvalidInclude < Exception; end
    class InvalidFilter < Exception; end
    class InvalidSortBy < Exception; end
    class InvalidArguments < Exception; end
    
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(RestPack::Resource::Pageable)
      base.extend(RestPack::Resource::Filterable)
      base.extend(RestPack::Resource::Sortable)
      base.extend(RestPack::Resource::Includable)
      base.extend(RestPack::Resource::Single)
      super
    end
    
    def as_resource(options = {})
      self
    end

    module ClassMethods
      def model_as_resource(model)
        model ? model.as_resource() : nil
      end
    end
  end
end