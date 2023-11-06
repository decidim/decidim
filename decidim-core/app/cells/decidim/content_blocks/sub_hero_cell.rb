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
        desc = decidim_sanitize_admin(translated_attribute(current_organization.description))

        # Strip the surrounding paragraph tag because it is not allowed within
        # a <hN> element.
        desc.gsub(%r{</p>\s+<p>}, "<br><br>").gsub(%r{<p>(((?!</p>).)*)</p>}mi, "\\1")
      end
    end
  end
end
