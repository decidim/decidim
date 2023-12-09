# frozen_string_literal: true

module Decidim
  module Admin
    class DestroyNewsletter < Decidim::Commands::DestroyResource
      private

      def invalid? = resource.sent?
    end
  end
end
