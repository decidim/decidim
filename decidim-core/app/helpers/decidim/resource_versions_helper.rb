# frozen_string_literal: true

module Decidim
  # Helper to print resource versions.
  module ResourceVersionsHelper
    include ResourceHelper

    # Displays the localized version for the given resource.
    #
    # resource - the Resource that has the version to display.
    # options - An optional hash of options
    #         * class: A string of extra css classes
    #
    # Returns a String.
    def resource_version(resource, options = {})
      return unless resource.respond_to?(:versions) && resource.versions_count.positive?

      path = options.delete(:versions_path)
      html = []
      html << resource_version_number(resource.versions_count)
      html << " "
      html << resource_version_of(resource.versions_count)
      html << " "
      html << link_to_other_resource_versions(path, options) if path.present?

      safe_join(html)
    end

    def resource_version_number(count, css_class = "")
      content_tag(:strong, t("version", scope: "decidim.versions.resource_version", number: count), class: css_class)
    end

    def resource_version_of(count)
      t("of_versions", scope: "decidim.versions.resource_version", number: count)
    end

    def link_to_other_resource_versions(versions_path, options = {})
      link_to(
        t(
          "see_other_versions",
          scope: "decidim.versions.resource_version"
        ),
        versions_path,
        **options
      )
    end
  end
end
