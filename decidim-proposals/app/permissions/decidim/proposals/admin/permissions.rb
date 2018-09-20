# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          if create_permission_action?
            # There's no special condition to create proposal notes, only
            # users with access to the admin section can do it.
            allow! if permission_action.subject == :proposal_note

            # Proposals can only be created from the admin when the
            # corresponding setting is enabled.
            toggle_allow(admin_creation_is_enabled?) if permission_action.subject == :proposal

            # Proposals can only be answered from the admin when the
            # corresponding setting is enabled.
            toggle_allow(admin_proposal_answering_is_enabled?) if permission_action.subject == :proposal_answer
          end

          # Admins can only edit official proposals if they are within the
          # time limit.
          allow! if admin_edition_is_available? && permission_action.subject == :proposal && permission_action.action == :edit

          # Every user allowed by the space can update the category of the proposal
          allow! if permission_action.subject == :proposal_category && permission_action.action == :update

          # Every user allowed by the space can import proposals from another_component
          allow! if permission_action.subject == :proposals && permission_action.action == :import

          permission_action
        end

        private

        def proposal
          @proposal ||= context.fetch(:proposal, nil)
        end

        def admin_creation_is_enabled?
          current_settings.try(:creation_enabled?) &&
            component_settings.try(:official_proposals_enabled)
        end

        def admin_edition_is_available?
          return unless proposal
          admin_creation_is_enabled? && proposal.official? && proposal.within_edit_time_limit?
        end

        def admin_proposal_answering_is_enabled?
          current_settings.try(:proposal_answering_enabled) &&
            component_settings.try(:proposal_answering_enabled)
        end

        def create_permission_action?
          permission_action.action == :create
        end
      end
    end
  end
end
