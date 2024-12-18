# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users wants to merge two or more
      # proposals into a new one to another proposal component in the same space.
      class ProposalsMergeForm < ProposalBaseForm
        translatable_attribute :title, String do |field, _locale|
          validates field, length: { in: 15..150 }, if: proc { |resource| resource.send(field).present? }
        end
        translatable_attribute :body, Decidim::Attributes::RichText
        attribute :proposal_ids, Array

        validates :proposal_ids, length: { minimum: 2 }

        def proposals
          @proposals ||= Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids).uniq
        end
      end
    end
  end
end
