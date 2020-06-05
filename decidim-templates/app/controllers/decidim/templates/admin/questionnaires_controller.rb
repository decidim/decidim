# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class QuestionnaireTemplatesController < Decidim::Templates::Admin::ApplicationController
        def index
          @templates = current_organization.templates.where(model_type: "Decidim::Forms::Questionnaire")
        end
      end
    end
  end
end
