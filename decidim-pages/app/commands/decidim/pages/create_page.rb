# frozen_string_literal: true
module Decidim
  module Pages
    # Command that gets called whenever a feature's page has to be created. It
    # usually happens as a callback when the feature itself is created.
    class CreatePage < Rectify::Command
      def initialize(feature)
        @feature = feature
      end

      def call
        @page = Page.new(
          title: @feature.name,
          feature: @feature
        )

        @page.save ? broadcast(:ok) : broadcast(:error)
      end
    end
  end
end
