# frozen_string_literal: true

module Decidim
  class VersionsListItemCell < Decidim::ViewModel
    include Decidim::LayoutHelper

    def version
      model
    end

    def versioned_resource
      options[:versioned_resource]
    end

    def index
      total - options[:index]
    end

    def total
      options[:total]
    end

    def version_path
      options[:version_path].call(index)
    end

    def i18n_version_index
      i18n("version_index", index:, total:)
    end

    def i18n(string, **params)
      t(string, **params, scope: i18n_scope, default: t(string, **params, scope: default_i18n_scope))
    end

    def i18n_scope
      options[:i18n_scope]
    end

    def default_i18n_scope
      "decidim.versions_list_item.show"
    end

    def html_options
      @html_options ||= options[:html_options] || {}
    end
  end
end
