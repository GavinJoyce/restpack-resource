require 'active_support/core_ext/hash'

module RESTpack
  module Resource
    module Sortable
      def resource_sortable_by
        @resource_sortable_by || []
      end
      def resource_sortable_by=(columns)
        @resource_sortable_by = columns
      end
      def resource_can_sort_by(*columns)
        self.resource_sortable_by += columns
      end
      def resource_validate_sort_by!(sort_by)
        raise InvalidSortBy.new unless sort_by.nil? || self.resource_sortable_by.include?(sort_by)
      end
    end
  end
end