# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create questions for a consultation from the admin dashboard.
      class QuestionConfigurationForm < Form
        mimic :question

        attribute :max_responses, Integer, default: 1
        attribute :min_responses, Integer, default: 1

        validates :max_responses, numericality: { greater_than_or_equal_to: 1 }
        validates :min_responses, numericality: { greater_than_or_equal_to: 1 }
      end
    end
  end
end
