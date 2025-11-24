# frozen_string_literal: true

module Decidim
  module Api
    class SessionsController < ::Devise::SessionsController
      skip_before_action :verify_authenticity_token

      respond_to :json

      def failure
        render json: resource_attributes(anonymous_user).merge(
          "jwt_token" => nil,
          "avatar" => nil
        ), status: :unauthorized
      end

      private

      def auth_options
        { scope: resource_name, recall: "#{controller_path}#failure" }
      end

      def after_sign_in_path_for(_resource_or_scope)
        nil
      end

      def respond_with(resource, _opts = {})
        serialized_user = resource_attributes(resource)

        if request.env[::Warden::JWTAuth::Middleware::TokenDispatcher::ENV_KEY]
          jwt_token = request.env[::Warden::JWTAuth::Hooks::PREPARED_TOKEN_ENV_KEY]
          return failure if jwt_token.blank?

          # Some systems (that is you Microsoft Power Automate (Flow)) may be
          # parsing off the headers which makes it difficult for the API users
          # to get the bearer token. This allows them to get it from the request
          # body instead.
          return render json: serialized_user.merge(
            "jwt_token" => jwt_token,
            "avatar" => nil
          ), status: :ok
        end

        # Since avatar can be ActiveStorage object now, it can cause infinite loops
        render json: serialized_user.merge("avatar" => nil)
      end

      def respond_to_on_destroy
        head :ok
      end

      def resource_attributes(resource)
        resource.attributes.slice("id", "name", "nickname")
      end

      def anonymous_user
        Decidim::Api::ApiUser.new(api_key: params.dig("api_user", "key"))
      end
    end
  end
end
