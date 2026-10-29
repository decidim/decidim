# frozen_string_literal: true

module Decidim
  module Pages
    # Command that gets called when the page of this component needs to be
    # destroyed. It usually happens as a callback when the component is removed.
    class DestroyPage < Decidim::Command
      def initialize(component)
        @component = component
      end

      def call
        # rubocop:disable-next Decidim/OrganizationScopedFinder -- the component is the component passed to the command
        Page.where(component: @component).destroy_all
        broadcast(:ok)
      end
    end
  end
end
