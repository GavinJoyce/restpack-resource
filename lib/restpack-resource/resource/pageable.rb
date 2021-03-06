require 'active_support/core_ext/hash'

module RestPack
  module Resource
    module Pageable      
      def paged_resource(options = {})
        options.reverse_merge!(
          :scope => self.all,
          :page => 1,
          :includes => [],
          :filters => {},
          :sort_by => nil,
          :sort_direction => :ascending
        )
        
        resource_normalise_options!(options)
        resource_validate_options!(options)
        
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
            foreign_keys = get_foreign_keys(paged_models, relationship)        
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
      
      def get_many_to_one_side_loads(paged_models, relationship)
        paged_models.map do |model|
          relation = model.send(relationship.name.to_sym)
          model_as_resource(relation)
        end
      end
      
      def get_foreign_keys(paged_models, relationship)
        parent_key_name = relationship.parent_key.first.name
        paged_models.map {|e| e.send(parent_key_name)}.uniq
      end
      
      def resource_collection_name
        self.name.to_s.downcase.pluralize.to_sym
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