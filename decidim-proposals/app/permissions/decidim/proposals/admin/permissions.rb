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
            permission_action.allow! if permission_action.subject == :proposal_note

            # Proposals can only be created from the admin when the
            # corresponding setting is enabled.
            permission_action.allow! if permission_action.subject == :proposal && admin_creation_is_enabled?

            # Proposals can only be answered from the admin when the
            # corresponding setting is enabled.
            permission_action.allow! if permission_action.subject == :proposal_answer && admin_proposal_answering_is_enabled?
          end

          # Every user allowed by the space can update the category of the proposal
          permission_action.allow! if permission_action.subject == :proposal_category && permission_action.action == :update

          # Every user allowed by the space can import proposals from another_component
          permission_action.allow! if permission_action.subject == :proposals && permission_action.action == :import

          permission_action
        end

        private

        def admin_creation_is_enabled?
          current_settings.try(:creation_enabled?) &&
            component_settings.try(:official_proposals_enabled)
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
