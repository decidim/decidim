# frozen_string_literal: true

module Decidim
  module Pages
    # Command that gets called when the page of this feature needs to be
    # destroyed. It usually happens as a callback when the feature is removed.
    class DestroyPage < Rectify::Command
      def initialize(feature)
        @feature = feature
      end

      def call
        Page.where(feature: @feature).destroy_all
        broadcast(:ok)
      end
    end
  end
end
