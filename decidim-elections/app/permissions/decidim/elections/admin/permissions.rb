# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          allowed_election_action?
          allowed_election_question_action?
          allowed_elections_census_action?

          permission_action
        end

        private

        def election
          @election ||= context.fetch(:election, nil)
        end

        def allowed_election_action?
          return unless permission_action.subject == :election

          case permission_action.action
          when :create, :read
            allow!
          when :update
            toggle_allow(election.present?)
          when :publish
            toggle_allow(election&.questions&.exists? && election&.census_ready? && !election&.published?)
          end
        end

        def allowed_election_question_action?
          return unless permission_action.subject == :election_question

          case permission_action.action
          when :update, :reorder
            toggle_allow(election.present?) # This logic will be updated once the final election question criteria are defined.
          end
        end

        def allowed_elections_census_action?
          return unless permission_action.subject == :census

          case permission_action.action
          when :edit
            allow!
          when :update
            toggle_allow(election.present?)
          end
        end
      end
    end
  end
end
