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
      EngineRouter.main_proxy(feature).root_path
    end

    # Returns the defined admin root path for a given feature.
    #
    # feature - the Feature we want to find the root path for.
    #
    # Returns a url.
    def manage_feature_path(feature)
      EngineRouter.admin_proxy(feature).root_path
    end
  end
end
