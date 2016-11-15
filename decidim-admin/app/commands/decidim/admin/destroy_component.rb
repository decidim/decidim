# frozen_string_literal: true
module Decidim
  module Admin
    class DestroyComponent < Rectify::Command
      def initialize(component)
        @component = component
      end

      def call
        @component.destroy ? broadcast(:ok) : broadcast(:error)
      end
    end
  end
end
