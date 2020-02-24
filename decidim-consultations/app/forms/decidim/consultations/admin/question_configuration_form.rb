# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A form object used to create questions for a consultation from the admin dashboard.
      class QuestionConfigurationForm < Form
        include TranslatableAttributes
        mimic :question

        attribute :max_votes, Integer, default: 1
        attribute :min_votes, Integer, default: 1
        translatable_attribute :instructions, String

        validates :max_votes, numericality: { greater_than_or_equal_to: 1 }
        validates :min_votes, numericality: { greater_than_or_equal_to: 1 }
        validate :min_lower_than_max

        def min_lower_than_max
          return if min_votes.to_i <= max_votes.to_i

          errors.add(:max_votes, :lower_than_min)
        end
      end
    end
  end
end
