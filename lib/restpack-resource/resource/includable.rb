require 'active_support/core_ext/hash'

module RestPack
  module Resource
    module Includable
      def resource_includable_associations
        @resource_includable_associations || []
      end
      def resource_includable_associations=(associations)
        @resource_includable_associations = associations.uniq
      end
      def resource_can_include(*associations)
        self.resource_includable_associations += associations
      end
      def resource_validate_includes!(includes)
        includes.each do |include|
          unless self.resource_includable_associations.include?(include.to_sym)
            raise InvalidInclude, "#{self.name}.#{include} is not an includable relation"
          end
        end
      end
    end
  end
end