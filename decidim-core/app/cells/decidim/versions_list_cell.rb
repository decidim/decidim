# frozen_string_literal: true

module Decidim
  class VersionsListCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def versioned_resource
      model
    end

    def resource_title
      decidim_html_escape(translated_attribute(versioned_resource.title))
    end

    def resource_path
      resource_locator(versioned_resource).path
    end

    def i18n_changes_title
      i18n("changes_at_title", title: resource_title)
    end

    def i18n_versions_title
      i18n("title")
    end

    def i18n_versions_count
      i18n("number_of_versions")
    end

    def i18n_back_to_resource
      i18n("back_to_resource")
    end

    def i18n(string, **params)
      t(string, **params, scope: i18n_scope, default: t(string, **params, scope: default_i18n_scope))
    end

    def i18n_scope
      options[:i18n_scope]
    end

    def default_i18n_scope
      "decidim.versions_list.show"
    end

    def version_path
      options[:version_path]
    end

    delegate :versions, to: :versioned_resource
  end
end
