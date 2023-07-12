# frozen_string_literal: true

module Decidim
  module Comments
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::Comments::Comment.not_hidden.where(author:)
      end
    end
  end
end
