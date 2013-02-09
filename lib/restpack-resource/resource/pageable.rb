require 'active_support/core_ext/hash'

module RESTpack
  module Resource
    module Pageable
      def resource_paged_resource(options = {})
        options.reverse_merge!(
          :scope => self.all,
          :page => 1,
          :includes => [],
          :filters => {},
          :sort_by => nil,
          :sort_direction => :ascending,
          :counts => []
        )
        resource_normalise_options!(options)
        resource_validate_options!(options)
        
        order = options[:sort_by]
        order = order.desc if order && options[:sort_direction] == :descending
        
        collection = options[:scope].all(:conditions => options[:filters]).page(options[:page], :order => order)         

        result = {
          :page => collection.pager.current_page,
          :page_count => collection.pager.total_pages,
          :total => collection.pager.total,
          :previous_page => collection.pager.previous_page,
          :next_page => collection.pager.next_page
        }

        unless collection.empty?
          result[self.resource_collection_name] = collection.map {|i| i.to_resource() }

          options[:includes].each do |association|
            target_model_name = association.to_s.singularize.capitalize              
            relationships = self.relationships.select {|r| r.target_model.to_s == target_model_name }
            raise InvalidInclude if relationships.empty?

            result[association] = []

            relationships.each do |relationship|
              unless relationship.is_a? DataMapper::Associations::ManyToOne::Relationship
                raise InvalidInclude, "#{self.name}.#{relationship.name} can't be included when paging #{self.name.pluralize.downcase}"
              end
              result[association] += collection.map do |entity| #TODO: GJ: PERF: we can bypass datamapper associations and get by a list of ids instead
                relation = entity.send(relationship.name.to_sym)
                relation ? relation.to_resource : nil
              end
              result[association].uniq!
              result[association].compact!
            end
          end
        end

        result
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