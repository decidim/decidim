# frozen_string_literal: true

module Decidim
  class ResourceAutocompleteController < Decidim::ApplicationController
    def index
      respond_to do |format|
        format.json do
          if term.blank?
            render json: [{ title: t("decidim.resource_autocomplete.help"), help: true }]
          else
            render json: serialized_results
          end
        end
      end
    end

    private

    def allowed_resource_types
      %w(Decidim::Proposals::Proposal)
    end

    def serialized_results
      search_results.map do |result|
        {
          gid: result.resource_global_id,
          title: result.content_a
        }
      end
    end

    def search_results
      Decidim::SearchableResource
        .where(
          resource_type: allowed_resource_types,
          organization: current_organization,
          decidim_participatory_space: current_participatory_space,
          locale: I18n.locale
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
