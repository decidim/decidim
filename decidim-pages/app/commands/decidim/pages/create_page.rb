# frozen_string_literal: true
module Decidim
  module Pages
    class CreatePage < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        @page = Page.create(
          title: @component.name,
          component: @component
        )

        return broadcast(:ok) if @page
        broadcast(:error)
      end
    end
  end
end
