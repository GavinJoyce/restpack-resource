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
      
      def association_relationships(association)
        target_model_name = association.to_s.singularize.capitalize              
        relationships = self.relationships.select {|r| r.target_model.to_s == target_model_name }
        raise InvalidInclude if relationships.empty?
        relationships
      end
      
      def get_child_models(relationship, foreign_keys, page_size)
        child_key_name = relationship.child_key.first.name
        relationship.child_model.all(child_key_name.to_sym => foreign_keys).page({ per_page: page_size })
      end
      
      def invalid_include(relationship)
        raise InvalidInclude, "#{self.name}.#{relationship.name} can't be included when paging #{self.name.pluralize.downcase}"
      end
    end
  end
end