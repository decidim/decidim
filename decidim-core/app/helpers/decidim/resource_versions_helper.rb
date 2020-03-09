# frozen_string_literal: true

module Decidim
  # Helper to print resource versions.
  module ResourceVersionsHelper
    # Displays the localized version for the given resource.
    #
    # resource - the Resource that has the version to display.
    # options - An optional hash of options
    #         * class: A string of extra css classes
    #
    # Returns a String.
    def resource_version(resource, options = {})
      return unless resource.respond_to?(:amendable?) && resource.amendable?

      html = %(<strong class="text-uppercase">#{localized_version("version", resource.versions_count)}</strong> #{localized_version("of_versions", resource.versions_count)})

      html += %( #{link_to(localized_version("see_other_versions"), options[:versions_path])}) if options[:versions_path]

      "<div class='tech-info #{options[:class]}'>#{html}</div>".html_safe
    end

    private

    def localized_version(string, count = nil)
      I18n.t(string, scope: "decidim.proposals.collaborative_drafts.show", number: count)
    end
  end
end
