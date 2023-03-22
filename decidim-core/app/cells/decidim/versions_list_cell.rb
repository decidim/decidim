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

    def i18n_scope
      options[:i18n_scope]
    end

    def version_path
      options[:version_path]
    end

    def total
      @total ||= versions.count
    end

    def reverse_ordered_versions
      @reverse_ordered_versions ||= relation? ? versions.reverse_order : versions.reverse
    end

    def relation?
      versions.is_a?(ActiveRecord::Relation)
    end

    delegate :versions, to: :versioned_resource
  end
end
