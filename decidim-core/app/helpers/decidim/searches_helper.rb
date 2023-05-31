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

      resource.model_name.human(count:)
    end

    # Generates a link to filter the current search by the given type. If no
    # type is given, it generates a link to the main results page.
    #
    # resource_type - An optional String with the name of the model class to filter
    # space_state - An optional String with the name of the state of the space
    def search_path_by(resource_type: nil, space_state: nil)
      new_params = {
        utf8: params[:utf8],
        filter: {
          with_scope: params.dig(:filter, :with_scope),
          term: params[:term] || params.dig(:filter, :term)
        }
      }
      new_params[:filter][:with_resource_type] = resource_type if resource_type.present?
      new_params[:filter][:with_space_state] = space_state if space_state.present?
      decidim.search_path(new_params)
    end

    # Generates the path to the main results page (the one without any filter
    # active), only the `term` one.
    def main_search_path
      search_path_by
    end

    # Generates the path to filter by resource type, considering the other filters.
    def search_path_by_resource_type(resource_type)
      search_path_by(space_state: params.dig(:filter, :with_space_state), resource_type:)
    end

    # Generates the path and link to filter by space state, taking into account
    # the other filters applied.
    def search_path_by_state_link(state)
      path = search_path_by(resource_type: params.dig(:filter, :with_resource_type), space_state: state)
      is_active = params.dig(:filter, :with_space_state).to_s == state.to_s

      link_to path, class: "order-by__tab#{" is-active" if is_active}" do
        content_tag(:strong, t(state || :all, scope: "decidim.searches.filters.state"))
      end
    end
  end
end
