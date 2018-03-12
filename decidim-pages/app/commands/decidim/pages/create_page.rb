# frozen_string_literal: true

module Decidim
  module Pages
    # Command that gets called whenever a component's page has to be created. It
    # usually happens as a callback when the component itself is created.
    class CreatePage < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        @page = Page.new(component: @component)

        @page.save ? broadcast(:ok) : broadcast(:invalid)
      end
    end
  end
end
