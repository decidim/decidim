# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module AjaxPermissionHandler
    extend ActiveSupport::Concern

    included do
      rescue_from Decidim::ActionForbidden, with: :ajax_user_has_no_permission
    end

    private

    def ajax_user_has_no_permission
      return user_has_no_permission unless request.xhr?

      render json: { message: I18n.t("actions.unauthorized", scope: "decidim.core") }, status: :unprocessable_entity
    end
  end
end
