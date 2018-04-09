# frozen_string_literal: true

module Decidim
  module Consultations
    class Response < ApplicationRecord
      belongs_to :question,
                 foreign_key: "decidim_consultations_questions_id",
                 class_name: "Decidim::Consultations::Question",
                 counter_cache: :responses_count,
                 inverse_of: :responses

      has_many :votes,
               foreign_key: "decidim_consultations_response_id",
               class_name: "Decidim::Consultations::Vote",
               inverse_of: :response,
               dependent: :restrict_with_error
    end
  end
end
