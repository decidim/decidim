# frozen_string_literal: true
require "active_support/concern"

module Decidim
  # This concern groups methods and helpers related to accessing the settings
  # of a feature from a controller.
  module FeatureSettings
    extend ActiveSupport::Concern

    included do
      include NeedsParticipatoryProcess

      helper_method :feature_settings, :current_settings

      delegate :active_step, to: :current_participatory_process, prefix: false

      def feature_settings
        current_feature.settings
      end

      def current_settings
        return nil unless active_step

        current_feature.step_settings.fetch(active_step.id.to_s)
      end
    end
  end
end
