# frozen_string_literal: true

module Decidim
  module Proposals
    class HideAllCreatedByAuthorJob < ::Decidim::HideAllCreatedByAuthorJob
      protected

      def perform(author:, justification:, current_user:)
        Decidim::Proposals::Proposal.not_hidden.from_author(author).find_each do |content|
          hide_content(content, current_user, justification)
        end
        Decidim::Proposals::CollaborativeDraft.not_hidden.from_author(author).find_each do |content|
          hide_content(content, current_user, justification)
        end
      end
    end
  end
end
