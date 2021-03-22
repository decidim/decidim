# frozen_string_literal: true

module Decidim
  class VersionAuthorCell < Decidim::ViewModel
    include Decidim::SanitizeHelper

    def author
      model
    end

    def author_name
      return nil unless author
      return t(".deleted") if author.deleted?

      author.name
    end
  end
end
