# frozen_string_literal: true
module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include NeedsOrganization
      include NeedsAuthorization
      include FormFactory
      include LocaleSwitcher

      protect_from_forgery with: :exception, prepend: true

      def user_not_authorized_path
        decidim_admin.root_path
      end

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability
        @current_ability ||= Decidim::Admin::Abilities::Base.new(current_user)
      end
    end
  end
end
