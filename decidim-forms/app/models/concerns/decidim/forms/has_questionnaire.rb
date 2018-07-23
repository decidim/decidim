# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Forms
    # A concern with the components needed when you want a model to be have a questionnaire attached
    module HasQuestionnaire
      extend ActiveSupport::Concern

      included do
        has_one :questionnaire,
                class_name: "Decidim::Forms::Questionnaire",
                dependent: :destroy,
                inverse_of: :questionnaire_for,
                as: :questionnaire_for
      end
    end
  end
end
