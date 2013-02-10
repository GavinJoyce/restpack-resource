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
        
        model_as_resource(model)
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
        
        resource_validate_includes! options[:includes]

        #TODO: GJ: other validations
        
        options
      end
    end
  end
end