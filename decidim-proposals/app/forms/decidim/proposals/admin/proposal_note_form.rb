# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalNoteForm < Decidim::Form
        mimic :proposal_note

        attribute :body, String

        validates :body, presence: true
      end
    end
  end
end
