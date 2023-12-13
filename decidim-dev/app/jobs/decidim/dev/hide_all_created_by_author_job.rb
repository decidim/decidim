# frozen_string_literal: true

module Decidim
  module Dev
    class HideAllCreatedByAuthorJob < Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::Dev::DummyResource.not_hidden.where(author:)
      end
    end
  end
end
