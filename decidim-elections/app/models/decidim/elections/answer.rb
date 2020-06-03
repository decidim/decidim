# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for an Answer in the Decidim::Elections component. It stores a
    # title, description and related resources and attachments.
    class Answer < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasAttachments
      include Decidim::HasAttachmentCollections
      include Traceable
      include Loggable

      delegate :component, to: :question
      delegate :organization, :participatory_space, to: :component

      belongs_to :question, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Question", inverse_of: :answers

      default_scope { order(weight: :asc, id: :asc) }

      def proposals
        linked_resources(:proposals, "related_proposals")
      end
    end
  end
end
