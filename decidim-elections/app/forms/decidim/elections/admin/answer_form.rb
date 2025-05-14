# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class AnswerForm < Decidim::Form
        mimic :answer

        include TranslatableAttributes

        translatable_attribute :statement, String

        validates :statement, translatable_presence: true

        def election
          @election ||= context[:election]
        end

        def question
          @question ||= context[:question]
        end
      end
    end
  end
end
