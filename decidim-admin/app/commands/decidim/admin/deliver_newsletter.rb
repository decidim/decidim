module Decidim
  module Admin
    class DeliverNewsletter < Rectify::Command
      def initialize(newsletter)
        @newsletter = newsletter
      end

      def call
        return broadcast(:invalid) if @newsletter.delivered?

        @newsletter.update_attributes!(
          delivered_at: Time.current
        )

        broadcast(:ok, @newsletter)
      end
    end
  end
end
