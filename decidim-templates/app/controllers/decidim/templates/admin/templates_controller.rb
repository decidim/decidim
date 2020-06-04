# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class TemplatesController < Decidim::Templates::Admin::ApplicationController
        def index
          @template_types = {
            questionnaires: decidim_admin_templates.questionnaire_templates_path
          }
        end
      end
    end
  end
end
