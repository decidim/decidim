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
            when :create
              allow!
            when :delete
              allow_if_not_related_to_any_election
            end
          when :trustee_participatory_space
            allow!
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

        def trustee
          @trustee ||= context.fetch(:trustee, nil)
        end

        def allow_if_not_started
          toggle_allow(election && !election.started?)
        end

        def allow_if_valid_and_not_started
          toggle_allow(election && !election.started? && election.valid_questions?)
        end

        def allow_if_not_related_to_any_election
          toggle_allow(trustee.elections.empty?)
        end
      end
    end
  end
end
