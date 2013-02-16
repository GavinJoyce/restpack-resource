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
          resource.merge! get_single_side_loads(model, association)
        end
        
        resource
      end
      
      def get_single_side_loads(model, association)        
        side_loads = {}
        resources = []

        association_relationships(association).each do |relationship|
          if relationship.is_a? DataMapper::Associations::ManyToOne::Relationship
            relation = model.send(relationship.name.to_sym)
            
            resources << (relation ? model_as_resource(relation) : nil)
          elsif relationship.is_a? DataMapper::Associations::OneToMany::Relationship
            parent_key_name = relationship.parent_key.first.name
            foreign_keys = [model.send(parent_key_name)]
            
            side_load = get_one_to_many_side_loads(relationship, foreign_keys)
            resources += side_load[:resources]
            side_loads[side_load[:count_key]] = side_load[:count]
          else
            invalid_include relationship
          end
        end

        side_loads[association] = resources.uniq.compact
        side_loads
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