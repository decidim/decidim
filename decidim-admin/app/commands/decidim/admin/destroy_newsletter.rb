# frozen_string_literal: true

module Decidim
  module Admin
    # This command deals with destroying a newsletter from the admin panel.
    class DestroyNewsletter < Decidim::Commands::DestroyResource
      private

      def invalid? = resource.sent?
    end
  end
end
