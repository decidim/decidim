# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a Component from the admin panel.
    class DestroyComponent < Decidim::Commands::DestroyResource
      private

      def run_before_hooks
        resource.manifest.run_hooks(:before_destroy, resource)
      end

      def run_after_hooks
        resource.manifest.run_hooks(:destroy, resource)
      end
    end
  end
end
