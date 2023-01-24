# frozen_string_literal: true

module Decidim
  class RedesignedVersionAuthorCell < RedesignedAuthorCell
    def display_name
      return super unless from_context.is_a?(PaperTrail::Version)

      author = Decidim.traceability.version_editor(from_context)
      return author if author.is_a?(String) && author.present?

      super
    end
  end
end
