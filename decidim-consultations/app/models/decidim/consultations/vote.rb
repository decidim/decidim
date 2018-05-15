# frozen_string_literal: true

module Decidim
  module Consultations
    # The data store for question's votes in the Decidim::Consultations component.
    class Vote < ApplicationRecord
      include Authorable
      include Decidim::DataPortability

      belongs_to :question,
                 foreign_key: "decidim_consultation_question_id",
                 class_name: "Decidim::Consultations::Question",
                 counter_cache: :votes_count,
                 inverse_of: :votes

      belongs_to :response,
                 foreign_key: "decidim_consultations_response_id",
                 class_name: "Decidim::Consultations::Response",
                 inverse_of: :votes,
                 counter_cache: :votes_count

      validates :author, uniqueness: { scope: [:decidim_user_group_id, :question] }

      delegate :organization, to: :question

      def self.user_collection(user)
        where(decidim_author_id: user.id)
      end

      def self.export_serializer
        Decidim::Consultations::DataPortabilityVoteSerializer
      end
    end
  end
end
