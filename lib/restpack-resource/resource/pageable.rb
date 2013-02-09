require 'active_support/core_ext/hash'

module RestPack
  module Resource
    module Pageable      
      def paged_resource(params = {}, overrides = {})
        options = build_options(params, overrides)
        
        get_paged_resource(options)
      end
      
      protected
      
      def get_paged_resource(options)
        page = get_page(options)        

        result = {
          :page => page.pager.current_page,
          :page_count => page.pager.total_pages,
          :total => page.pager.total,
          :previous_page => page.pager.previous_page,
          :next_page => page.pager.next_page
        }

        unless page.empty?
          result[self.resource_collection_name] = page.map {|i| i.to_resource() }

          options[:includes].each do |association|
            result[association] = side_load(page, association)
          end
        end

        result
      end
      
      def get_page(options)
        order = options[:sort_by]
        order = order.desc if order && options[:sort_direction] == :descending
        
        options[:scope].all(:conditions => options[:filters]).page(options[:page], :order => order)
      end
      
      def side_load(page, association)
        target_model_name = association.to_s.singularize.capitalize              
        relationships = self.relationships.select {|r| r.target_model.to_s == target_model_name }
        raise InvalidInclude if relationships.empty?

        side_loaded_entities = []

        relationships.each do |relationship|
          unless relationship.is_a? DataMapper::Associations::ManyToOne::Relationship
            raise InvalidInclude, "#{self.name}.#{relationship.name} can't be included when paging #{self.name.pluralize.downcase}"
          end
          side_loaded_entities += page.map do |entity| #TODO: GJ: PERF: we can bypass datamapper associations and get by a list of ids instead
            relation = entity.send(relationship.name.to_sym)
            relation ? relation.to_resource : nil
          end
          side_loaded_entities.uniq!
          side_loaded_entities.compact!
        end
        
        side_loaded_entities
      end
      
      def resource_collection_name
        self.name.to_s.downcase.pluralize.to_sym
      end
      
      def build_options(params, overrides)        
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