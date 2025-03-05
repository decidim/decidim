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
      Decidim::SearchableResource
        .where(
          resource_type: allowed_resource_types,
          organization: current_organization,
          decidim_participatory_space: current_participatory_space
        )
        .autocomplete_search(term)
        .limit(10)
    end

    def term
      params[:term]
    end

    def participatory_space_gid
      params[:participatory_space_gid]
    end

    def current_participatory_space
      @current_participatory_space ||= GlobalID::Locator.locate(participatory_space_gid)
    end
  end
end
