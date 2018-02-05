# frozen-string_literal: true

module Decidim
  class FeaturePublishedEvent < Decidim::Events::SimpleEvent
    include Decidim::FeaturePathHelper

    def resource_path
      @resource_path ||= main_feature_path(resource)
    end

    def resource_url
      @resource_url ||= main_feature_url(resource)
    end

    def resource_title
      @resource_title ||= resource.name[I18n.locale.to_s]
    end
  end
end
