# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::ApplicationController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/templates"

        helper_method :template_types

        def template_types
          @template_types ||= {
            I18n.t("template_types.questionnaires", scope: "decidim.templates") => decidim_admin_templates.questionnaire_templates_path
          }
        end
      end
    end
  end
end
