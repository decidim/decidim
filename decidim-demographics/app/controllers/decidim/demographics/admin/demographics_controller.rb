# frozen_string_literal: true

module Decidim
  module Demographics
    module Admin
      # Exposes the meeting resource so users can view them
      class DemographicsController < Admin::ApplicationController
        def index
          flash[:alert] = I18n.t("demographics.management.disabled", scope: "decidim.admin")
          redirect_to parent_path
        end

        private

        def current_component
          request.env["decidim.current_component"]
        end

        def current_participatory_space
          current_component.participatory_space
        end

        def parent_path
          @parent_path ||= ::Decidim::EngineRouter.admin_proxy(current_participatory_space).components_path
        end
      end
    end
  end
end
