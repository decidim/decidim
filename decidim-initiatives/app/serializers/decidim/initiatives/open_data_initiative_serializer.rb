# frozen_string_literal: true

module Decidim
  module Initiatives
    class OpenDataInitiativeSerializer < Decidim::Exporters::ParticipatorySpaceSerializer
      # Public: Exports a hash with the serialized data for this initiative.
      #
      # Note that we do not merge the original serialize method here, as the Initiative
      # model does not have the same attributes as the other Spaces models.
      def serialize
        {
          reference: resource.reference,
          title: resource.title,
          url: EngineRouter.main_proxy(resource).initiative_url(resource),
          description: resource.description,
          state: resource.state,
          created_at: resource.created_at,
          updated_at: resource.updated_at,
          published_at: resource.published_at,
          signature_start_date: resource.signature_start_date,
          signature_end_date: resource.signature_end_date,
          signature_type: resource.signature_type,
          signatures: resource.supports_count,
          answer: resource.answer,
          answered_at: resource.answered_at,
          answer_url: resource.answer_url,
          first_progress_notification_at: resource.first_progress_notification_at,
          second_progress_notification_at: resource.second_progress_notification_at,
          online_votes: resource.online_votes,
          offline_votes: resource.offline_votes,
          comments_count: resource.comments_count,
          follows_count: resource.follows_count,
          scope: {
            id: resource.scope.try(:id),
            name: resource.scope.try(:name) || empty_translatable
          },
          type: {
            id: resource.type&.id,
            title: resource.type&.title
          },
          authors: {
            id: resource.author_users.map(&:id),
            name: resource.author_users.map(&:name)
          },
          area: {
            id: resource.area.try(:id),
            name: resource.area.try(:name) || empty_translatable
          }
        }
      end
    end
  end
end
