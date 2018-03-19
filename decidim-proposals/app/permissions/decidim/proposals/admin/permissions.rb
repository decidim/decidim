# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class Permissions
        def initialize(user, permission_action, context)
          @user = user
          @permission_action = permission_action
          @context = context
        end

        def allowed?
          # Stop checks if the user is not authorized to perform the
          # permission_action for this space
          return false unless spaces_allows_user?

          # The public part needs to be implemented yet
          return false if permission_action.scope != :admin

          if create_permission_action?
            # There's no special condition to create proposal notes, only
            # users with access to the admin section can do it.
            return true if permission_action.subject == :proposal_note

            # Proposals can only be created from the admin when the
            # corresponding setting is enabled.
            return true if permission_action.subject == :proposal && admin_creation_is_enabled?

            # Proposals can only be answered from the admin when the
            # corresponding setting is enabled.
            return true if permission_action.subject == :proposal_answer && admin_proposal_answering_is_enabled?
          end

          # Every user allowed by the space can update the category of the proposal
          return true if permission_action.subject == :proposal_category && permission_action.action == :update

          # Every user allowed by the space can import proposals from another_component
          return true if permission_action.subject == :proposals && permission_action.action == :import

          false
        end

        private

        attr_reader :user, :permission_action, :context

        def spaces_allows_user?
          return unless space.manifest.permissions_class
          space.manifest.permissions_class.new(user, permission_action, context).allowed?
        end

        def current_settings
          @current_settings ||= context.fetch(:current_settings, nil)
        end

        def component_settings
          @component_settings ||= context.fetch(:component_settings, nil)
        end

        def space
          @space ||= context.fetch(:current_component, nil)&.participatory_space
        end

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
