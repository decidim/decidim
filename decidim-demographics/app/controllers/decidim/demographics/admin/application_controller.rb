# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::ApplicationController`, which
      # overrides its layout and provides all kinds of useful methods.
      class ApplicationController < Decidim::Admin::ApplicationController
        register_permissions(::Decidim::Demographics::Admin::ApplicationController,
                             ::Decidim::Demographics::Admin::Permissions,
                             ::Decidim::Admin::Permissions)

        layout "decidim/admin/insights"

        add_breadcrumb_item_from_menu :admin_settings_menu

        private

        def questionnaire
          @questionnaire ||= Decidim::Forms::Questionnaire.where(questionnaire_for:).first_or_create
          @questionnaire.override_edit!
          @questionnaire
        end

        def questionnaire_for
          demographic
        end

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Demographics::Admin::ApplicationController)
        end

        def demographic
          @demographic ||= Decidim::Demographics::Demographic.where(organization: current_organization).first_or_create!
        end
      end
    end
  end
end
