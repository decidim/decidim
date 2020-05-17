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
      return unless resource.respond_to?(:amendable?) && resource.amendable?

      html = %(<strong>#{localized_version("version", resource.versions_count)}</strong> #{localized_version("of_versions", resource.versions_count)})

      html += %( #{link_to(other_versions_text(resource), options[:versions_path])}) if options[:versions_path]

      "<div class='tech-info #{options[:class]}'>#{html}</div>".html_safe
    end

    private

    def localized_version(string, count = nil)
      context_translation(string, number: count)
    end

    def other_versions_text(resource)
      context_translation("see_other_versions", resource_name: decidim_html_escape(resource_title(resource)))
    end

    def context_translation(key, arguments = {})
      I18n.t(key, arguments.merge(scope: "decidim.proposals.collaborative_drafts.show"))
    end
  end
end
