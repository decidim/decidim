# frozen_string_literal: true

module Decidim
  class ResourceAutocompleteController < Decidim::ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: search_results.map { |result|
            {
              gid: result.resource_global_id,
              title: result.content_a
            }
          }
        end
      end
    end

    private

    def allowed_resource_types
      %w(Decidim::Proposals::Proposal)
    end

    def search_results
      # TODO: Scope by current participatory space?
      Decidim::SearchableResource
        .where(resource_type: allowed_resource_types, organization: current_organization)
        .autocomplete_search(term)
        .limit(10)
    end

    def term
      params[:term]
    end
  end
end
