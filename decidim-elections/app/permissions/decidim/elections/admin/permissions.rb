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
            when :delete, :update, :unpublish
              allow_if_not_started
            when :publish
              allow_if_valid_and_not_started
            end
          when :trustee
            case permission_action.action
            when :create, :update, :delete
              allow!
            end
          end

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end

        def question
          @question ||= context.fetch(:question, nil)
        end

        def allow_if_not_started
          toggle_allow(election && !election.started?)
        end

        def allow_if_valid_and_not_started
          toggle_allow(election && !election.started? && election.valid_questions?)
        end
      end
    end
  end
end
