# frozen_string_literal: true
module Decidim
  module Pages
    class DestroyPage < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        Page.where(component: @component).destroy_all
        broadcast(:ok)
      end
    end
  end
end
