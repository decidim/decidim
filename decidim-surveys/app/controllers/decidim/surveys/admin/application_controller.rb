# frozen_string_literal: true

module Decidim
  module Surveys
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :public_url

        layout :layout_for_action

        private

        def layout_for_action
          "decidim/admin/surveys" unless %w(index new create).include?(action_name) && controller_name == "surveys"
        end

        def public_url
          Decidim::EngineRouter.main_proxy(current_component).survey_path(survey)
        end
      end
    end
  end
end
