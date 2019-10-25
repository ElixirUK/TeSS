# Inspired by SEEK's breadcrumbs library
# https://github.com/seek4science/seek/blob/02d63e9e483deb466ee9097252446c02b5837916/lib/seek/breadcrumbs.rb

module BreadCrumbs
  extend ActiveSupport::Concern

  private

  # Make sure this is called after the @resource is set!
  def set_breadcrumbs
    add_base_breadcrumbs(controller_name)

    resource = instance_variable_get("@#{controller_name.singularize}")
    if resource
      add_show_breadcrumb resource if (resource.respond_to?(:new_record?) && !resource.new_record?)

      add_breadcrumb action_name.capitalize.humanize, polymorphic_path(resource) unless action_name == 'show'
    elsif action_name != 'index'
      add_breadcrumb action_name.capitalize.humanize, url_for(controller: controller_name, action: action_name, only_path: true)
    end
  end

  def add_base_breadcrumbs(con_name = controller_name)
    #Home
    add_breadcrumb 'Home', root_path

    #Index
    add_index_breadcrumb(con_name)
  end

  def add_index_breadcrumb(con_name, breadcrumb_name = nil)
    breadcrumb_name ||= con_name.singularize.humanize.pluralize
    add_breadcrumb breadcrumb_name, url_for(controller: "/#{con_name}", action: 'index', type: nil, only_path: true)
  end

  def add_show_breadcrumb resource, breadcrumb_name = nil
    breadcrumb_name ||= if resource.respond_to?(:title)
                          resource.title
                        elsif resource.respond_to?(:name) && resource.name.present?
                          resource.name
                        else
                          resource.id
                        end

    add_breadcrumb breadcrumb_name, polymorphic_path(resource)
  end

  def add_breadcrumb(name, url = '', options = {})
    @breadcrumbs ||= []
    @breadcrumbs << { name: name, url: url, options: options }
  end
end
