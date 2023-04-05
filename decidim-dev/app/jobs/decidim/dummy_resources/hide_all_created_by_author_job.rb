# frozen_string_literal: true

module Decidim
  module DummyResources
    class HideAllCreatedByAuthorJob < Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::DummyResources::DummyResource.not_hidden.where(author:)
      end
    end
  end
end
