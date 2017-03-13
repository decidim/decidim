# frozen_string_literal: true
module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include NeedsOrganization
      include NeedsAuthorization
      include FormFactory
      include LocaleSwitcher
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper
      helper Decidim::OrganizationScopesHelper
      helper Decidim::TranslationsHelper

      helper Decidim::LanguageChooserHelper

      protect_from_forgery with: :exception, prepend: true

      def user_not_authorized_path
        decidim_admin.root_path
      end

      # Overwrites `cancancan`'s method to point to the correct ability class,
      # since the gem expects the ability class to be in the root namespace.
      def current_ability_klass
        Decidim::Admin::Abilities::Base
      end

      def append_info_to_payload(payload)
        super
        payload[:user_id] = current_user.id
        payload[:organization_id] = current_organization.id
        payload[:app] = current_organization.name
        payload[:remote_ip] = request.remote_ip
        payload[:referer] = request.referer.to_s
        payload[:request_id] = request.uuid
        payload[:user_agent] = request.user_agent
        payload[:xhr] = request.xhr? ? 'true' : 'false'
      end
    end
  end
end
