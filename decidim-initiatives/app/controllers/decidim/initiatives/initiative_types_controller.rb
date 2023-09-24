# frozen_string_literal: true

# i18n-tasks-use t('decidim.initiatives.show.badge_name.accepted')
# i18n-tasks-use t('decidim.initiatives.show.badge_name.created')
# i18n-tasks-use t('decidim.initiatives.show.badge_name.discarded')
# i18n-tasks-use t('decidim.initiatives.show.badge_name.published')
# i18n-tasks-use t('decidim.initiatives.show.badge_name.rejected')
# i18n-tasks-use t('decidim.initiatives.show.badge_name.validating')
#
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
