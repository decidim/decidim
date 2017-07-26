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
      feature_root_path_for(feature.manifest.engine, feature)
    end

    # Returns the defined admin root path for a given feature.
    #
    # feature - the Feature we want to find the root path for.
    #
    # Returns a url.
    def manage_feature_path(feature)
      feature_root_path_for(feature.manifest.admin_engine, feature)
    end

    private

    def feature_root_path_for(engine, feature)
      url_params = {
        feature_id: feature.id,
        participatory_process_id: feature.participatory_process.id
      }

      engine.routes.url_helpers.root_path(url_params)
    end
  end
end
