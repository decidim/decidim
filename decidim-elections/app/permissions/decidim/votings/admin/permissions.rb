# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          return permission_action if voting && !voting.is_a?(Decidim::Votings::Voting)

          unless user.admin?
            disallow!
            return permission_action
          end

          user_can_enter_space_area?

          if read_admin_dashboard_action?
            allow!
            return permission_action
          end

          allowed_read_participatory_space?
          allowed_action_on_component?
          allowed_voting_action?

          permission_action
        end

        private

        def user_can_enter_space_area?
          return unless permission_action.action == :enter &&
                        permission_action.subject == :space_area &&
                        context.fetch(:space_name, nil) == :votings

          allow!
        end

        def read_admin_dashboard_action?
          permission_action.action == :read &&
            permission_action.subject == :admin_dashboard
        end

        def allowed_read_participatory_space?
          return unless permission_action.action == :read &&
                        permission_action.subject == :participatory_space

          allow!
        end

        def allowed_action_on_component?
          return unless permission_action.subject == :component

          allow!
        end

        def allowed_voting_action?
          return unless [:votings, :voting].member? permission_action.subject

          case permission_action.subject
          when :votings
            toggle_allow(user.admin?) if permission_action.action == :read
          when :voting
            case permission_action.action
            when :read, :create, :publish, :unpublish
              allow!
            when :update, :preview
              toggle_allow(voting.present?)
            end
          end
        end

        def voting
          @voting ||= context.fetch(:voting, nil) || context.fetch(:participatory_space, nil)
        end
      end
    end
  end
end
