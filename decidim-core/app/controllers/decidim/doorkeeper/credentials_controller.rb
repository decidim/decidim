# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # A controller to expose a simple JSON API so OAuth clients can get the user's information.
    class CredentialsController < ApplicationController
      before_action :doorkeeper_authorize!
      respond_to :json

      def me
        respond_with public_data
      end

      private

      def public_data
        {
          id: current_resource_owner.id,
          email: current_resource_owner.email,
          name: current_resource_owner.name,
          nickname: current_resource_owner.nickname,
          image: avatar_url
        }
      end

      def current_resource_owner
        @current_resource_owner ||= Decidim::User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def avatar_url
        avatar_url = current_resource_owner.attached_uploader(:avatar).url
        return unless avatar_url

        unless %r{^https?://}.match? avatar_url
          request_uri = URI.parse(request.url)
          request_uri.path = avatar_url
          request_uri.query = nil
          avatar_url = request_uri.to_s
        end

        avatar_url
      end
    end
  end
end
