# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users wants to split two or more
      # proposals into a new one to another proposal component in the same space.
      class ProposalsSplitForm < Decidim::Form
        mimic :proposals_import

        attribute :target_component_id, Integer
        attribute :proposal_ids, Array

        validates :target_component, :proposals, :current_component, presence: true
        validate :same_participatory_space

        def proposals
          @proposals ||= Decidim::Proposals::Proposal.where(component: current_component, id: proposal_ids).uniq
        end

        def target_component
          @target_component ||= current_component.siblings.find_by(id: target_component_id)
        end

        private

        def same_participatory_space
          return if !target_component || !current_component

          errors.add(:target_component, :invalid) if current_component.participatory_space != target_component.participatory_space
        end
      end
    end
  end
end
