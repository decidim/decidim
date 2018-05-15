# frozen_string_literal: true

module Decidim
  module Consultations
    class DataPortabilityVoteSerializer < Decidim::Exporters::Serializer
      # Serializes a Vore for data portability
      def serialize
        {
          id: resource.id,
          question: {
            id: resource.question.id,
            title: resource.question.title,
            subtitle: resource.question.subtitle,
            what_is_decided: resource.question.what_is_decided,
            promoter_group: resource.question.promoter_group,
            participatory_scope: resource.question.participatory_scope,
            question_context: resource.question.question_context,
            published_at: resource.question.published_at,
            created_at: resource.question.created_at,
            updated_at: resource.question.updated_at,
            consultation: {
              id: resource.question.consultation.id,
              slug: resource.question.consultation.slug,
              title: resource.question.consultation.title,
              subtitle: resource.question.consultation.subtitle,
              description: resource.question.consultation.description,
              introductory_video_url: resource.question.consultation.introductory_video_url,
              start_voting_date: resource.question.consultation.start_voting_date,
              end_voting_date: resource.question.consultation.end_voting_date,
              results_published_at: resource.question.consultation.results_published_at
            }
          },
          response: {
            id: resource.response.id,
            title: resource.response.title,
            created_at: resource.response.created_at,
            updated_at: resource.response.updated_at
          },
          created_at: resource.created_at,
          updated_at: resource.updated_at
        }
      end
    end
  end
end
