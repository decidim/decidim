# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module SuspensionChecker
    extend ActiveSupport::Concern

    included do
      before_action :check_user_not_suspended
    end

    def check_user_not_suspended
      check_user_suspend_status(current_user)
    end

    def check_user_suspend_status(user)
      if user.present? && user.blocked?
        sign_out user
        flash.delete(:notice)
        flash[:error] = t("decidim.account.blocked")
        root_path
      end
    end
  end
end
