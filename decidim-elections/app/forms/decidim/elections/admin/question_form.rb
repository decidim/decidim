# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a Form to create/update questions from Decidim's admin panel.
      class QuestionForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        attribute :max_selections, Integer, default: 1
        attribute :weight, Integer, default: 0
        attribute :random_answers_order, Boolean, default: true
        attribute :min_selections, Integer, default: 1

        validates :title, translatable_presence: true
        validates :max_selections, presence: true, numericality: { greater_than_or_equal_to: 1 }

        def election
          @election ||= context[:election]
        end
      end
    end
  end
end
