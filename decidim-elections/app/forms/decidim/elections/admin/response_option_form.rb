# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class ResponseOptionForm < Decidim::Form
        mimic :answer

        include TranslatableAttributes

        attribute :deleted, Boolean, default: false

        translatable_attribute :body, String

        validates :body, translatable_presence: true, unless: :deleted

        def election
          @election ||= context[:election]
        end

        def question
          @question ||= context[:question]
        end

        def to_param
          return id if id.present?

          "questionnaire-question-response-option-id"
        end
      end
    end
  end
end
