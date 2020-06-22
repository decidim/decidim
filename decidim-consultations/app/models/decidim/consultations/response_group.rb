# frozen_string_literal: true

module Decidim
  module Consultations
    class ResponseGroup < ApplicationRecord
      include Decidim::TranslatableResource

      translatable_fields :title

      belongs_to :question,
                 foreign_key: "decidim_consultations_questions_id",
                 class_name: "Decidim::Consultations::Question",
                 counter_cache: :response_groups_count,
                 inverse_of: :response_groups

      has_many :responses,
               foreign_key: "decidim_consultations_response_group_id",
               class_name: "Decidim::Consultations::Response",
               inverse_of: :response_group,
               dependent: :restrict_with_error
    end
  end
end
