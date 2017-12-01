# frozen_string_literal: true

module Decidim
  # A helper to get the root path for a feature.
  module FeaturePathHelper
    # Returns the defined root path for a given feature.
    #
    # feature - the Feature we want to find the root path for.
    #
    # Returns a url.
    def main_feature_path(feature)
      current_params = try(:params) || {}
      EngineRouter.main_proxy(feature).root_path(locale: current_params[:locale])
    end

    # Returns the defined admin root path for a given feature.
    #
    # feature - the Feature we want to find the root path for.
    #
    # Returns a url.
    def manage_feature_path(feature)
      current_params = try(:params) || {}
      EngineRouter.admin_proxy(feature).root_path(locale: current_params[:locale])
    end
  end
end
