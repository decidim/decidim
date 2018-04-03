# frozen_string_literal: true

module Decidim
  module Initiatives
    module InitiativeSlug
      def slug_from_id(id)
        "i-#{id}"
      end

      def id_from_slug(slug)
        return slug if /\A\d+\Z/.match?(slug)

        slug[2..-1] if slug.present?
      end
    end
  end
end
