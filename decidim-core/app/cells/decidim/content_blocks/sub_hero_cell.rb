# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class SubHeroCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::SanitizeHelper

      def show
        return if translated_attribute(current_organization.description).blank?

        render
      end

      private

      def organization_description
        desc = decidim_sanitize(translated_attribute(current_organization.description))

        # Strip the surrounding paragraph tag because it is not allowed within
        # a <hN> element.
        desc.sub(/^<p>/, "").sub(%r{</p>$}, "")
      end
    end
  end
end
