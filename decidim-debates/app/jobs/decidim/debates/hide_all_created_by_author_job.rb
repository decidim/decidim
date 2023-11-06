# frozen_string_literal: true

module Decidim
  module Debates
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::Debates::Debate.not_hidden.where(author:)
      end
    end
  end
end
