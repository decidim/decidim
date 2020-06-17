# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :question, :answer
            case permission_action.action
            when :create, :update, :delete
              allow_if_not_started
            when :import_proposals
              allow_if_not_started
            end
          when :election
            case permission_action.action
            when :create, :read
              allow!
            when :update
              toggle_allow(election)
            when :delete
              allow_if_not_started
            end
          end

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end

        def allow_if_not_started
          toggle_allow(election && !election.started?)
        end
      end
    end
  end
end
