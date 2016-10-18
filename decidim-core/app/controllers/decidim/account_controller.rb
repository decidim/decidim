# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # The controller to handle the user's account page.
  class AccountController < ApplicationController
    helper_method :authorizations, :handlers

    private

    def handlers
      @handlers ||= Decidim.authorization_handlers.reject do |handler|
        authorized_handlers.include?(handler.handler_name)
      end
    end

    def authorizations
      @authorizations ||= current_user.authorizations
    end

    def authorized_handlers
      authorizations.map(&:name)
    end
  end
end
