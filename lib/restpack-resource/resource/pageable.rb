require 'active_support/core_ext/hash'

module RestPack
  module Resource
    module Pageable      
      def paged_resource(params = {}, overrides = {})
        options = build_paged_options(params, overrides)
        get_paged_resource(options)
      end
      
      protected
      
      def get_paged_resource(options)
        paged_models = get_paged_models(options)        

        paged_resource = {
          :page => paged_models.pager.current_page,
          :page_count => paged_models.pager.total_pages,
          :count => paged_models.pager.total,
          :previous_page => paged_models.pager.previous_page,
          :next_page => paged_models.pager.next_page
        }

        paged_resource[self.resource_collection_name] = paged_models.map { |model| model_as_resource(model) }

        unless paged_models.empty?
          options[:includes].each do |association|
            paged_resource.merge! get_side_loads(paged_models, association)
          end
        end

        paged_resource
      end
      
      def get_paged_models(options)
        order = options[:sort_by]
        order = order.desc if order && options[:sort_direction] == :descending
        
        options[:scope].all(:conditions => options[:filters]).page(options[:page], :order => order)
      end
      
      def get_side_loads(paged_models, association)
        side_loads = {}
        resources = []

        association_relationships(association).each do |relationship|
          if relationship.is_a? DataMapper::Associations::ManyToOne::Relationship
            resources += get_many_to_one_side_loads(paged_models, relationship)
          elsif relationship.is_a? DataMapper::Associations::OneToMany::Relationship            
            side_load = get_one_to_many_side_loads(paged_models, relationship)
            resources += side_load[:resources]
            side_loads[side_load[:count_key]] = side_load[:count]
          else
            invalid_include relationship
          end
        end
        
        side_loads[association] = resources.uniq.compact
        side_loads
      end
      
      def get_many_to_one_side_loads(paged_models, relationship)
        paged_models.map do |model|
          relation = model.send(relationship.name.to_sym)
          model_as_resource(relation)
        end
      end
      
      def get_one_to_many_side_loads(paged_models, relationship)
        result = {}            
        children = get_child_models(paged_models, relationship, 100) #TODO: GJ: configurable side-load page size
        result[:resources] = children.map {|c| c.as_resource() }
        result[:count_key] = "#{relationship.child_model_name.downcase}_count".to_sym
        result[:count] = children.pager.total
        result
      end
      
      def get_child_models(paged_models, relationship, page_size = 100)
        child_key_name = relationship.child_key.first.name
        foreign_keys = get_foreign_keys(paged_models, relationship)
        relationship.child_model.all(child_key_name.to_sym => foreign_keys).page({ per_page: page_size })
      end
      
      def get_foreign_keys(paged_models, relationship)
        parent_key_name = relationship.parent_key.first.name
        paged_models.map {|e| e.send(parent_key_name)}.uniq
      end
      
      def resource_collection_name
        self.name.to_s.downcase.pluralize.to_sym
      end
      
      def build_paged_options(params, overrides)        
        options = overrides.reverse_merge( #overrides take precedence over params
          :page => params[:page],
          :includes => params[:includes].nil? ? [] : params[:includes].split(','),
          :filters =>  self.extract_filters_from_params(params),
          :sort_by => params[:sort_by], 
          :sort_direction => params[:sort_direction]
        )
        
        options.reverse_merge!( #defaults
          :scope => self.all,
          :page => 1,
          :includes => [],
          :filters => {},
          :sort_by => nil,
          :sort_direction => :ascending
        )

        resource_normalise_options!(options)
        resource_validate_options!(options)
        
        options
      end
      
      def extract_filters_from_params(params)
        extracted = params.extract!(*self.resource_filterable_by)
        extracted.delete_if { |k, v| v.nil? }
      end
      
      private
      
      def resource_normalise_options!(options)
        options[:includes].map!{|i| i.to_sym}
        
        [:sort_by, :sort_direction].each do |attribute|
          options[attribute] = options[attribute].to_sym if options[attribute]
        end
      end
      
      def resource_validate_options!(options)
        self.resource_validate_includes! options[:includes]
        self.resource_validate_filters! options[:filters]
        self.resource_validate_sort_by! options[:sort_by] 
      end
    end
  end
end