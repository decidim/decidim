# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          # Valuators can only perform these actions
          if user_is_valuator?
            if valuator_assigned_to_proposal?
              can_create_proposal_note?
              can_create_proposal_answer?
            end
            can_export_proposals?
            valuator_can_unassign_valuator_from_proposals?

            return permission_action
          end

          if create_permission_action?
            can_create_proposal_note?
            can_create_proposal_from_admin?
            can_create_proposal_answer?
          end

          # Admins can only edit official proposals if they are within the
          # time limit.
          allow! if permission_action.subject == :proposal && permission_action.action == :edit && admin_edition_is_available?

          # Every user allowed by the space can update the category of the proposal
          allow! if permission_action.subject == :proposal_category && permission_action.action == :update

          # Every user allowed by the space can update the scope of the proposal
          allow! if permission_action.subject == :proposal_scope && permission_action.action == :update

          # Every user allowed by the space can import proposals from another_component
          allow! if permission_action.subject == :proposals && permission_action.action == :import

          # Every user allowed by the space can export proposals
          can_export_proposals?

          # Every user allowed by the space can merge proposals to another component
          allow! if permission_action.subject == :proposals && permission_action.action == :merge

          # Every user allowed by the space can split proposals to another component
          allow! if permission_action.subject == :proposals && permission_action.action == :split

          # Every user allowed by the space can assign proposals to a valuator
          allow! if permission_action.subject == :proposals && permission_action.action == :assign_to_valuator

          # Every user allowed by the space can unassign a valuator from proposals
          can_unassign_valuator_from_proposals?

          # Only admin users can publish many answers at once
          toggle_allow(user.admin?) if permission_action.subject == :proposals && permission_action.action == :publish_answers

          if permission_action.subject == :participatory_texts && participatory_texts_are_enabled? && permission_action.action == :manage
            # Every user allowed by the space can manage (import, update and publish) participatory texts to proposals
            allow!
          end

          permission_action
        end

        private

        def proposal
          @proposal ||= context.fetch(:proposal, nil)
        end

        def user_valuator_role
          @user_valuator_role ||= space.user_roles(:valuator).find_by(user:)
        end

        def user_is_valuator?
          return if user.admin?

          user_valuator_role.present?
        end

        def valuator_assigned_to_proposal?
          @valuator_assigned_to_proposal ||=
            Decidim::Proposals::ValuationAssignment
            .where(proposal:, valuator_role: user_valuator_role)
            .any?
        end

        def admin_creation_is_enabled?
          current_settings.try(:creation_enabled?) &&
            component_settings.try(:official_proposals_enabled)
        end

        def admin_edition_is_available?
          return unless proposal

          (proposal.official? || proposal.official_meeting?) && proposal.votes.empty?
        end

        def admin_proposal_answering_is_enabled?
          current_settings.try(:proposal_answering_enabled) &&
            component_settings.try(:proposal_answering_enabled)
        end

        def create_permission_action?
          permission_action.action == :create
        end

        def participatory_texts_are_enabled?
          component_settings.participatory_texts_enabled?
        end

        # There's no special condition to create proposal notes, only
        # users with access to the admin section can do it.
        def can_create_proposal_note?
          allow! if permission_action.subject == :proposal_note
        end

        # Proposals can only be created from the admin when the
        # corresponding setting is enabled.
        # This setting is incompatible with participatory texts.
        def can_create_proposal_from_admin?
          return disallow! if participatory_texts_are_enabled? && permission_action.subject == :proposal

          toggle_allow(admin_creation_is_enabled?) if permission_action.subject == :proposal
        end

        # Proposals can only be answered from the admin when the
        # corresponding setting is enabled.
        def can_create_proposal_answer?
          toggle_allow(admin_proposal_answering_is_enabled?) if permission_action.subject == :proposal_answer
        end

        def can_unassign_valuator_from_proposals?
          allow! if permission_action.subject == :proposals && permission_action.action == :unassign_from_valuator
        end

        def valuator_can_unassign_valuator_from_proposals?
          can_unassign_valuator_from_proposals? if user == context.fetch(:valuator, nil)
        end

        def can_export_proposals?
          allow! if permission_action.subject == :proposals && permission_action.action == :export
        end
      end
    end
  end
end
