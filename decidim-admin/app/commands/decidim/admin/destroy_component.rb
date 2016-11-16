# frozen_string_literal: true
module Decidim
  module Admin
    class DestroyComponent < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        transaction do
          destroy_component
          run_hooks
        end
      end

      private

      def destroy_component
        @component.destroy ? broadcast(:ok) : broadcast(:error)
      end

      def run_hooks
        @component.manifest.config.dig(:hooks, :destroy)&.call(@component)
      end
    end
  end
end
