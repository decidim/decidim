# frozen_string_literal: true

module Decidim
  class VersionAuthorCell < AuthorCell
    def display_name
      return super unless from_context.is_a?(PaperTrail::Version)
      return author if author.is_a?(String) && author.present?

      super
    end

    def author
      @author ||= Decidim.traceability.version_editor(from_context)
    end
  end
end
