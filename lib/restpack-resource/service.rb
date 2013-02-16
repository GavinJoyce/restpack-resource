require 'active_support/core_ext/hash/slice.rb'

module RestPack
  module Service
  
    def paged_resource(klass, params, options = {})
      options[:page] ||= params[:page].to_i if params[:page]
      options[:includes] ||= extract_includes_from_params(params) unless params[:includes].nil?
      options[:sort_by] ||= params[:sort_by].to_sym if params[:sort_by]
      options[:sort_direction] ||= params[:sort_direction].to_sym if params[:sort_direction]
      
      filters = extract_filters_from_params(klass, params)
      options[:filters] ||= filters unless filters.empty?
      
      klass.paged_resource(options)
    end
    
    def single_resource(klass, params, options = {})      
      options[:id] ||= params[:id] if params[:id]
      options[:includes] ||= extract_includes_from_params(params) unless params[:includes].nil?
      
      klass.single_resource(options)
    end
    
    private
  
    def extract_filters_from_params(klass, params)
      extracted = params.extract!(*klass.resource_filterable_by)
      extracted.delete_if { |k, v| v.nil? }
    end
    
    def extract_includes_from_params(params)
      params[:includes].split(',').map {|i| i.to_sym }
    end
    
  end
end