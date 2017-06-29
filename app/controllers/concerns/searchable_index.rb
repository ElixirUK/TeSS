module SearchableIndex
  extend ActiveSupport::Concern

  included do
    attr_reader :facet_fields, :search_params, :facet_params, :page, :sort_by, :index_resources
    before_action :set_params, only: [:index, :count_events]
    before_action :fetch_resources, only: [:index, :count_events]

    helper 'search'
  end

  def fetch_resources
    if TeSS::Config.solr_enabled
      page = params[:page].blank? ? 1 : params[:page]
      per_page = params[:per_page].blank? ? 30 : params[:per_page]

      @search_results = @model.search_and_filter(current_user, @search_params, @facet_params,
                                    page: page, per_page: per_page, sort_by: @sort_by)
      @index_resources = @search_results.results
      instance_variable_set("@#{controller_name}_results", @search_results) # e.g. @nodes_results
    else
      @index_resources = policy_scope(@model).paginate(page: @page)
    end

    instance_variable_set("@#{controller_name}", @index_resources) # e.g. @nodes
  end

  def set_params
    @model = controller_name.classify.constantize
    @facet_params = @model.send(:facet_params, params).permit!
    @search_params = params[:q] || ''
    @sort_by = params[:sort].blank? ? 'default' : params[:sort]
  end



end
