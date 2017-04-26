# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module PayloadInfo
    extend ActiveSupport::Concern

    included do
      def append_info_to_payload(payload)
        super
        payload[:user_id] = try(:current_user).try(:id)
        payload[:organization_id] = try(:current_organization).try(:id)
        payload[:app] = try(:current_organization).try(:name)
        payload[:remote_ip] = request.remote_ip
        payload[:referer] = request.referer.to_s
        payload[:request_id] = request.uuid
        payload[:user_agent] = request.user_agent
        payload[:xhr] = request.xhr? ? "true" : "false"
      end
    end
  end
end
