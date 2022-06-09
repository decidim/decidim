# frozen_string_literal: true

module Decidim
  class VersionCell < Decidim::ViewModel
    include Decidim::TraceabilityHelper
    include Decidim::SanitizeHelper

    def resource_title
      decidim_html_escape(translated_attribute(versioned_resource.title))
    end

    def current_version
      model
    end

    def versioned_resource
      options[:versioned_resource]
    end

    def versions_path
      options[:versions_path].call
    end

    def i18n_changes_title
      i18n("changes_at_title", title: resource_title)
    end

    def i18n_version_number
      i18n("version_number")
    end

    def i18n_back_to_resource
      i18n("back_to_resource")
    end

    def i18n_version_number_out_of_total
      i18n("version_number_out_of_total", current_version: index, total_count: versioned_resource.versions.count)
    end

    def i18n_show_all_versions
      i18n("show_all_versions")
    end

    def i18n_version_author
      i18n("version_author")
    end

    def i18n_version_created_at
      i18n("version_created_at")
    end

    def i18n(string, **params)
      t(string, **params, scope: i18n_scope, default: t(string, **params, scope: default_i18n_scope))
    end

    def i18n_scope
      options[:i18n_scope]
    end

    def default_i18n_scope
      "decidim.version.show"
    end

    def index
      options[:index]
    end

    def resource_path
      resource_locator(versioned_resource).path
    end
  end
end
