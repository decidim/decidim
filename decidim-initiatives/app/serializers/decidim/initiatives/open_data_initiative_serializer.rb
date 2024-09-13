# frozen_string_literal: true

module Decidim
  module Initiatives
    class OpenDataInitiativeSerializer < Decidim::Exporters::Serializer
      # Serializes an initiative
      def serialize
        {
          reference: resource.reference,
          title: resource.title,
          description: resource.description,
          state: resource.state,
          created_at: resource.created_at,
          published_at: resource.published_at,
          signature_start_date: resource.signature_start_date,
          signature_end_date: resource.signature_end_date,
          signature_type: resource.signature_type,
          signatures: resource.supports_count,
          answer: resource.answer,
          answered_at: resource.answered_at,
          answer_url: resource.answer_url,
          hashtag: resource.hashtag,
          first_progress_notification_at: resource.first_progress_notification_at,
          second_progress_notification_at: resource.second_progress_notification_at,
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
