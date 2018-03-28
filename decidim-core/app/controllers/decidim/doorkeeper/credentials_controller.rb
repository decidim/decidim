# frozen_string_literal: true

module Decidim
  module Doorkeeper
    # A controller to expose a simple JSON API so OAuth clients can get the user's information.
    class CredentialsController < ApplicationController
      skip_authorization_check
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
          nickname: current_resource_owner.nickname
        }
      end

      def current_resource_owner
        @current_resource_owner ||= Decidim::User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
