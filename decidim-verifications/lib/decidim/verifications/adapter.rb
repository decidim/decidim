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

      def root_path(redirect_url: nil)
        if manifest.type == "direct"
          decidim_verifications.new_authorization_path(handler: name, redirect_url: redirect_url)
        else
          main_engine.send(:root_path, redirect_url: redirect_url)
        end
      end

      def resume_authorization_path(redirect_url: nil)
        if manifest.type == "direct"
          raise InvalidDirectVerificationRoute.new(route: "edit_authorization_path")
        end

        main_engine.send(:edit_authorization_path, redirect_url: redirect_url)
      end

      def admin_root_path
        if manifest.type == "direct"
          raise InvalidDirectVerificationROute.new(route: "admin_route_path")
        end

        public_send(:"decidim_admin_#{name}").send(:root_path)
      end

      private

      attr_reader :manifest

      def main_engine
        send("decidim_#{manifest.name}")
      end
    end
  end
end
