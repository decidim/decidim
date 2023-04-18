# frozen_string_literal: true

module Decidim
  module Meetings
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def base_query
        Decidim::Meetings::Meeting.not_hidden.where(author:)
      end
    end
  end
end
