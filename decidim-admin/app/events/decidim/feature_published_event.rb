# frozen-string_literal: true

module Decidim
  class FeaturePublishedEvent < Decidim::Events::ExtendedEvent
    include Decidim::FeaturePathHelper

    i18n_attributes :participatory_space_title

    private

    def resource_path
      @resource_path ||= main_feature_path(resource)
    end

    def resource_url
      @resource_url ||= main_feature_url(resource)
    end

    def participatory_space_title
      resource.participatory_space.title[I18n.locale.to_s]
    end

    def resource_title
      @resource_title ||= resource.name[I18n.locale.to_s]
    end
  end
end
