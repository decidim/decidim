# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # Controller that allows managing templates.
      #
      class TemplatesController < Decidim::Templates::Admin::ApplicationController
        layout "decidim/admin/templates"

        def index
          @template_types = {
            I18n.t("template_types.questionnaires", scope: "decidim.templates") => decidim_admin_templates.questionnaire_templates_path
          }
        end
      end
    end
  end
end
