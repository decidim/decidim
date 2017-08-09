# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern groups methods and helpers related to accessing the settings
  # of a feature from a controller.
  module Settings
    extend ActiveSupport::Concern

    included do
      helper_method :feature_settings, :current_settings

      def feature_settings
        @feature_settings ||= current_feature.settings
      end

      def current_settings
        @current_settings ||= current_feature.current_settings
      end
    end
  end
end
