# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers related to accessing the settings
  # of a component from a controller.
  module Settings
    extend ActiveSupport::Concern

    included do
      helper_method :component_settings, :current_settings

      def component_settings
        @component_settings ||= current_component.settings
      end

      def current_settings
        @current_settings ||= current_component.current_settings
      end
    end
  end
end
