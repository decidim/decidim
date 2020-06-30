# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A controller concern to enable flagging capabilities to its resources. Only
  # affects the UI, so make sure you check the controller resources implement
  # the `Decidim::Reportable` model concern.
  module Flaggable
    extend ActiveSupport::Concern

    included do
      helper_method :flaggable_controller?

      def flaggable_controller?
        true
      end
    end
  end
end
