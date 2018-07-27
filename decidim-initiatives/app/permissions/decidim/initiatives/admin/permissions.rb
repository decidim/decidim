# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin
          return permission_action unless user

          user_can_enter_space_area?

          return permission_action if initiative && !initiative.is_a?(Decidim::Initiative)

          user_can_read_participatory_space?

          if !user.admin? && initiative&.has_authorship?(user)
            initiative_committee_action?
            initiative_user_action?
            attachment_action?

            return permission_action
          end

          if !user.admin? && has_initiatives?
            read_initiative_list_action?

            return permission_action
          end

          return permission_action unless user.admin?

          initiative_type_action?
          initiative_type_scope_action?
          initiative_committee_action?
          initiative_admin_user_action?
          allow! if permission_action.subject == :attachment

          permission_action
        end

        private

        def initiative
          @initiative ||= context.fetch(:initiative, nil) || context.fetch(:current_participatory_space, nil)
        end

        def user_can_read_participatory_space?
          return unless permission_action.action == :read &&
                        permission_action.subject == :participatory_space

          toggle_allow(user.admin? || initiative.has_authorship?(user))
        end

        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :initiatives

          toggle_allow(user.admin? || has_initiatives?)
        end

        def has_initiatives?
          (InitiativesCreated.by(user) | InitiativesPromoted.by(user)).any?
        end

        def attachment_action?
          return unless permission_action.subject == :attachment

          attachment = context.fetch(:attachment, nil)
          attached = attachment&.attached_to

          case permission_action.action
          when :update, :destroy
            toggle_allow(attached && attached.is_a?(Decidim::Initiative))
          when :read, :create
            allow!
          else
            disallow!
          end
        end

        def initiative_type_action?
          return unless permission_action.subject == :initiative_type

          initiative_type = context.fetch(:initiative_type, nil)

          case permission_action.action
          when :destroy
            scopes_are_empty = initiative_type && initiative_type.scopes.all? { |scope| scope.initiatives.empty? }
            toggle_allow(scopes_are_empty)
          else
            allow!
          end
        end

        def initiative_type_scope_action?
          return unless permission_action.subject == :initiative_type_scope

          initiative_type_scope = context.fetch(:initiative_type_scope, nil)

          case permission_action.action
          when :destroy
            scopes_is_empty = initiative_type_scope && initiative_type_scope.initiatives.empty?
            toggle_allow(scopes_is_empty)
          else
            allow!
          end
        end

        def initiative_committee_action?
          return unless permission_action.subject == :initiative_committee_member

          request = context.fetch(:request, nil)

          case permission_action.action
          when :index
            allow!
          when :approve
            toggle_allow(!request&.accepted?)
          when :revoke
            toggle_allow(!request&.rejected?)
          end
        end

        def initiative_admin_user_action?
          return unless permission_action.subject == :initiative

          case permission_action.action
          when :read
            toggle_allow(Decidim::Initiatives.print_enabled)
          when :publish
            toggle_allow(initiative.validating?)
          when :unpublish
            toggle_allow(initiative.published?)
          when :discard
            toggle_allow(initiative.validating?)
          when :export_votes
            toggle_allow(initiative.offline? || initiative.any?)
          when :accept
            allowed = initiative.published? &&
                      initiative.signature_end_date < Date.current &&
                      initiative.percentage >= 100
            toggle_allow(allowed)
          when :reject
            allowed = initiative.published? &&
                      initiative.signature_end_date < Date.current &&
                      initiative.percentage < 100
            toggle_allow(allowed)
          else
            allow!
          end
        end

        def read_initiative_list_action?
          return unless permission_action.subject == :initiative &&
                        permission_action.action == :list
          allow!
        end

        def initiative_user_action?
          return unless permission_action.subject == :initiative

          case permission_action.action
          when :read
            toggle_allow(Decidim::Initiatives.print_enabled)
          when :preview, :edit
            allow!
          when :update
            toggle_allow(initiative.created?)
          when :send_to_technical_validation
            allowed = initiative.created? && (
                        !initiative.decidim_user_group_id.nil? ||
                          initiative.committee_members.approved.count >= Decidim::Initiatives.minimum_committee_members
                      )

            toggle_allow(allowed)
          when :manage_membership
            allow!
          else
            disallow!
          end
        end
      end
    end
  end
end
