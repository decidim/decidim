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

      delegate :organization, :participatory_space, to: :component

      belongs_to :question, foreign_key: "decidim_elections_question_id", class_name: "Decidim::Elections::Question", inverse_of: :answers
      has_one :election, through: :question, foreign_key: "decidim_elections_election_id", class_name: "Decidim::Elections::Election"
      has_one :component, through: :election, foreign_key: "decidim_component_id", class_name: "Decidim::Component"

      default_scope { order(weight: :asc, id: :asc) }

      # Public: Get all the proposals related to the answer
      #
      # Returns an ActiveRecord::Relation.
      def proposals
        linked_resources(:proposals, "related_proposals")
      end
    end
  end
end
