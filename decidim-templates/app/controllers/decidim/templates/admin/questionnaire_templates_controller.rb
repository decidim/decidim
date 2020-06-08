# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class QuestionnaireTemplatesController < Decidim::Templates::Admin::ApplicationController
        include Decidim::Templates::Admin::Concerns::HasTemplates

        def templatable_type
          "Decidim::Forms::Questionnaire"
        end
      end
    end
  end
end
