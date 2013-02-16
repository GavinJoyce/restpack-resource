module RestPack
  module Resource
    module Single      
      def single_resource(params = {}, overrides = {})
        options = build_single_options(params, overrides)
        get_single_resource(options)
      end
      
      protected
      
      def get_single_resource(options)
        model = self.get(options[:id])
        
        raise "404" unless model #TODO: GJ: decide on error handling / status
        resource = model_as_resource(model)
        
        options[:includes].each do |association|
          add_single_side_loads(resource, model, association)
        end
        
        resource
      end
      
      def add_single_side_loads(resource, model, association)
        target_model_name = association.to_s.singularize.capitalize  
        side_loaded_entities = []

        association_relationships(association).each do |relationship|
          if relationship.is_a? DataMapper::Associations::ManyToOne::Relationship
            relation = model.send(relationship.name.to_sym)
            
            side_loaded_entities << (relation ? model_as_resource(relation) : nil)
          elsif relationship.is_a? DataMapper::Associations::OneToMany::Relationship
            parent_key_name = relationship.parent_key.first.name
            child_key_name = relationship.child_key.first.name
            foreign_key = model.send(parent_key_name)
                
            #TODO: GJ: configurable side-load page size
            children = relationship.child_model.all(child_key_name.to_sym => foreign_key).page({ per_page: 100 })
            side_loaded_entities += children.map { |c| model_as_resource(c) }
            
            count_key = "#{relationship.child_model_name.downcase}_count".to_sym
            resource[count_key] = children.pager.total
          else
            invalid_include relationship
          end
        end
        
        side_loaded_entities.uniq!
        side_loaded_entities.compact!
        
        resource[association] = side_loaded_entities
      end
      
      def build_single_options(params, overrides)        
        options = overrides.reverse_merge( #overrides take precedence over params
          :id => params[:id],
          :includes => params[:includes].nil? ? [] : params[:includes].split(',') #TODO: GJ: refactor, repeated in pageable
        )
        
        options.reverse_merge!( #defaults
          :includes => []
        )

        raise InvalidArguments, "id must be specified" unless params[:id]
        
        resource_normalise_options!(options)
        resource_validate_options!(options)
        #TODO: GJ: other validations
        options
      end
    end
  end
end