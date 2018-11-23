# frozen_string_literal: true

module Decidim
  # A Helper to render and link to searchables.
  module SearchesHelper
    # Renders the human name of the given class name.
    #
    # klass_name - a String representing the class name of the resource to render
    # count - (optional) the number of resources so that the I18n backend
    #         can decide to translate into singluar or plural form.
    def searchable_resource_human_name(resource, count: 5)
      resource = if resource.is_a?(String)
                   resource.constantize
                 else
                   resource
                 end

      resource.model_name.human(count: count)
    end

    # Generates a link to filter the current search by the given type. If no
    # type is given, it generates a link to the main results page.
    #
    # type - An optional String with the name of the model class to filter
    def search_path_by_type(type)
      new_params = {
        utf8: params[:utf8],
        filter: {
          term: params[:term] || params.dig(:filter, :term)
        }
      }
      new_params[:filter][:resource_type] = type if type.present?
      decidim.search_path(new_params)
    end

    def main_search_path
      search_path_by_type(nil)
    end
  end
end
