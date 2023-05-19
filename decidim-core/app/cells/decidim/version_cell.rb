# frozen_string_literal: true

module Decidim
  class VersionCell < Decidim::ViewModel
    include Decidim::TraceabilityHelper
    include Decidim::LayoutHelper
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

    def path
      options[:path]
    end

    def versions_path
      options[:versions_path].call
    end

    def i18n_changes_title
      i18n("changes_at_title", title: resource_title)
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
      "decidim.version.show"
    end

    def index
      options[:index]
    end

    def html_options
      @html_options ||= options[:html_options] || {}
    end
  end
end
