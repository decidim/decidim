# frozen_string_literal: true

module Decidim
  module Verifications
    class InvalidVerificationRoute < StandardError
      def new(route:)
        msg = <<~MSG
          You specified a direct handler but you're trying to use `#{route}`
          which is only available for multi-step authorization workflows. Change
          your workflow to define an engine with a `#{route}` route.
        MSG

        super(msg)
      end
    end

    class UnregisteredVerificationManifest < StandardError
    end

    #
    # Provides a unified interface for direct and deferred authorizations, so
    # they can be used transparently
    #
    class Adapter
      include Rails.application.routes.mounted_helpers

      def self.from_collection(collection)
        collection.map { |e| from_element(e) }
      end

      def self.from_element(element)
        manifest = Verifications.find_workflow_manifest(element)

        raise UnregisteredVerificationManifest unless manifest

        new(manifest)
      end

      def initialize(manifest)
        @manifest = manifest
      end

      delegate :key, :name, :fullname, :description, :type, to: :manifest

      #
      # Main entry point for the verification engine
      #
      def root_path(redirect_url: nil)
        if manifest.type == "direct"
          decidim_verifications.new_authorization_path(redirect_params(handler: name, redirect_url: redirect_url))
        else
          main_engine.send(:root_path, redirect_params(redirect_url: redirect_url))
        end
      end

      #
      # In the case of deferred authorizations, route to resume an authorization
      # process. Otherwise it rises
      #
      def resume_authorization_path(redirect_url: nil)
        raise InvalidDirectVerificationRoute.new(route: "edit_authorization_path") if manifest.type == "direct"

        main_engine.send(:edit_authorization_path, redirect_params(redirect_url: redirect_url))
      end

      #
      # Administrational entry point for the verification engine
      #
      def admin_root_path
        raise InvalidDirectVerificationRoute.new(route: "admin_route_path") if manifest.type == "direct"

        public_send(:"decidim_admin_#{name}").send(:root_path, redirect_params)
      end

      #
      # Authorize user to perform an action using the authorization handler action authorizer.
      # Saves the action_authorizer object with its context for subsequent methods calls.
      #
      # authorization - The existing authorization record to be evaluated. Can be nil.
      # options       - A hash with options related only to the current authorization process.
      # component     - The component where the authorization is taking place.
      # resource      - The resource where the authorization is taking place. Can be nil.
      #
      # Returns the result of authorization handler check. Check Decidim::Verifications::DefaultActionAuthorizer class docs.
      #
      def authorize(authorization, options, component, resource)
        @action_authorizer = @manifest.action_authorizer_class.new(authorization, options, component, resource)
        @action_authorizer.authorize
      end

      private

      attr_reader :manifest

      def main_engine
        send("decidim_#{manifest.name}")
      end

      def redirect_params(params = {})
        # Could add redirect params if a ActionAuthorizer object was previously set.
        params.merge(@action_authorizer&.redirect_params || {})
      end
    end
  end
end
