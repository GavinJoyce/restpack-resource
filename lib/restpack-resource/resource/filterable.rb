require 'active_support/core_ext/hash'

module RestPack
  module Resource
    module Filterable
      def resource_filterable_by
        @resource_filterable_by || []
      end
      def resource_filterable_by=(columns)
        @resource_filterable_by = columns
      end
      def resource_can_filter_by(*columns)
        self.resource_filterable_by += columns
      end
      def resource_validate_filters!(filters)
        return unless filters
        filters.keys.each do |filter|
          raise InvalidFilter.new unless self.resource_filterable_by.include?(filter)
        end
      end
    end
  end
end