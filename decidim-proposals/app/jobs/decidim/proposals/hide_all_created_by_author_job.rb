# frozen_string_literal: true

module Decidim
  module Proposals
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def perform(resource:, extra: {})
        return unless extra.fetch(:hide, false)

        Decidim::Proposals::Proposal.not_hidden.from_author(resource).find_each do |content|
          hide_content(content, extra[:event_author], extra[:justification])
        end
        Decidim::Proposals::CollaborativeDraft.not_hidden.from_author(resource).find_each do |content|
          hide_content(content, extra[:event_author], extra[:justification])
        end
      end
    end
  end
end
