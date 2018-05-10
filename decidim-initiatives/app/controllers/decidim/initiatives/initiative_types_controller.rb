# frozen_string_literal: true

module Decidim
  module Initiatives
    # Exposes the initiative type text search so users can choose a type writing its name.
    class InitiativeTypesController < Decidim::Initiatives::ApplicationController
      # GET /initiative_types/search
      def search
        enforce_permission_to :search, :initiative_type

        types = FreetextInitiativeTypes.for(current_organization, I18n.locale, params[:term])
        render json: { results: types.map { |type| { id: type.id.to_s, text: type.title[I18n.locale.to_s] } } }
      end
    end
  end
end
