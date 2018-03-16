# frozen_string_literal: true

module Decidim
  module Proposals
    module Abilities
      # Defines the abilities related to proposals for a logged in admin user.
      # Intended to be used with `cancancan`.
      class AdminAbility < Decidim::Abilities::AdminAbility
        def define_abilities
          super

          can :manage, Proposal
          can :unreport, Proposal
          can :hide, Proposal
          cannot :create, Proposal unless can_create_proposal?
          cannot :update, Proposal unless can_update_proposal?
          can :create, ProposalNote
        end

        private

        def current_settings
          @context.fetch(:current_settings, nil)
        end

        def component_settings
          @context.fetch(:component_settings, nil)
        end

        def can_create_proposal?
          current_settings.try(:creation_enabled?) &&
            component_settings.try(:official_proposals_enabled)
        end

        def can_update_proposal?
          current_settings.try(:proposal_answering_enabled) &&
            component_settings.try(:proposal_answering_enabled)
        end
      end
    end
  end
end
