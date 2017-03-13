# frozen_string_literal: true
module Decidim
  module System
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include FormFactory
      protect_from_forgery with: :exception, prepend: true

      helper Decidim::TranslationsHelper
      helper Decidim::DecidimFormHelper
      helper Decidim::ReplaceButtonsHelper

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
