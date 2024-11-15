# frozen_string_literal: true

module Decidim
  module Conferences
    # This class serializes a Conference so it can be exported to CSV for the Open Data feature.
    class OpenDataConferenceSerializer < Decidim::Exporters::ParticipatorySpaceSerializer
      # Public: Exports a hash with the serialized data for this conference.
      def serialize
        super.merge(
          {
            url: EngineRouter.main_proxy(resource).conference_url(resource),
            slogan: resource.slogan,
            remote_hero_image_url: Decidim::Conferences::ConferencePresenter.new(resource).hero_image_url,
            remote_banner_image_url: Decidim::Conferences::ConferencePresenter.new(resource).banner_image_url,
            location: resource.location,
            objectives: resource.objectives,
            start_date: resource.start_date,
            end_date: resource.end_date,
            scopes_enabled: resource.scopes_enabled,
            decidim_scope_id: resource.decidim_scope_id,
            scope: {
              id: resource.scope.try(:id),
              name: resource.scope.try(:name) || empty_translatable
            }
          }
        )
      end
    end
  end
end
