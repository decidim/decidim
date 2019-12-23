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

      info = "<strong class='text-medium text-uppercase'>#{localized_version(resource)}</strong>
      <small class='text-small'>#{localized_version(resource)}</small>"

      if options[:versions_path]
        info.concat link_to(I18n.t("see_other_versions", scope:"decidim.proposals.collaborative_drafts.show"), options[:versions_path])
      end

      "<div class='version-info #{options[:class]}'>#{info}</div>".html_safe
    end

    private

    def localized_version(resource)
      I18n.t("version", scope:"decidim.proposals.collaborative_drafts.show", number: resource.versions_count)
    end

    def localized_version_of(resource)
      I18n.t("of_versions", scope:"decidim.proposals.collaborative_drafts.show", number: resource.versions_count)
    end
  end
end
