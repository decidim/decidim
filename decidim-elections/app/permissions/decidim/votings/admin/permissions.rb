# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return user_allowed_to_read_admin_dashboard? if read_admin_dashboard_action?
          return permission_action unless permission_action.scope == :admin

          user_can_enter_space_area?

          return permission_action if voting && !voting.is_a?(Decidim::Votings::Voting)

          unless user_can_read_votings_admin_dashboard?
            disallow!
            return permission_action
          end

          allowed_read_participatory_space?
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

        def allowed_voting_action?
          return unless
          [
            :votings, :voting,
            :landing_page,
            :components,
            :polling_station, :polling_stations,
            :polling_officer, :polling_officers,
            :monitoring_committee_menu, :monitoring_committee_member, :monitoring_committee_members,
            :monitoring_committee_polling_station_closure, :monitoring_committee_polling_station_closures,
            :monitoring_committee_verify_elections,
            :monitoring_committee_election_result, :monitoring_committee_election_results,
            :census,
            :ballot_style, :ballot_styles
          ].member? permission_action.subject

          case permission_action.subject
          when :votings
            toggle_allow(user_can_read_votings_admin_dashboard?) if permission_action.action == :read
          when :voting
            case permission_action.action
            when :read, :list, :edit
              toggle_allow(user_can_read_voting?)
            when :create, :publish, :unpublish, :update
              toggle_allow(user.admin?)
            when :preview
              toggle_allow(user_can_read_voting? && voting.present?)
            when :manage_landing_page
              toggle_allow(user.admin? && voting.present?)
            end
          when :landing_page
            toggle_allow(user.admin?) if permission_action.action == :update
          when :ballot_styles, :components, :polling_stations, :polling_officers, :monitoring_committee_members
            toggle_allow(user.admin?) if permission_action.action == :read
          when :polling_station
            case permission_action.action
            when :create
              toggle_allow(user.admin?)
            when :update
              toggle_allow(user.admin? && polling_station.present?)
            when :delete
              toggle_allow(user.admin? && polling_station.present? && polling_station.closures.blank?)
            end
          when :polling_officer
            case permission_action.action
            when :create
              toggle_allow(user.admin?)
            when :delete
              toggle_allow(user.admin? && polling_officer.present?)
            end
          when :monitoring_committee_member
            case permission_action.action
            when :create
              toggle_allow(user.admin?)
            when :delete
              toggle_allow(user.admin? && monitoring_committee_member.present?)
            end
          when :monitoring_committee_menu
            toggle_allow(user_can_read_voting?) if permission_action.action == :read
          when :monitoring_committee_polling_station_closure
            toggle_allow(user_monitoring_committee_for_voting? && closure.present?) if [:read, :validate].member?(permission_action.action)
          when :monitoring_committee_polling_station_closures, :monitoring_committee_verify_elections, :monitoring_committee_election_results
            toggle_allow(user_monitoring_committee_for_voting?) if permission_action.action == :read
          when :monitoring_committee_election_result
            toggle_allow(user_monitoring_committee_for_voting? && election.present?) if [:read, :validate].member?(permission_action.action)
          when :census
            toggle_allow(user.admin?) if permission_action.action == :manage
          when :ballot_style
            case permission_action.action
            when :create
              toggle_allow(user.admin? && (voting.dataset.blank? || voting.dataset.init_data?))
            when :update, :delete
              toggle_allow(user.admin? && (voting.dataset.blank? || voting.dataset.init_data?) && ballot_style.present?)
            end
          end
        end

        # Monitoring committee members can access the admin dashboard to manage their votings.
        def user_allowed_to_read_admin_dashboard?
          toggle_allow(user_can_read_votings_admin_dashboard?)

          permission_action
        end

        def user_can_read_votings_admin_dashboard?
          user.admin? || user_monitoring_committee?
        end

        def user_can_read_voting?
          user.admin? || user_monitoring_committee_for_voting?
        end

        def user_monitoring_committee?
          Decidim::Votings::MonitoringCommitteeMember.exists?(user:)
        end

        def user_monitoring_committee_for_voting?
          Decidim::Votings::MonitoringCommitteeMember.exists?(user:, voting:)
        end

        def voting
          @voting ||= context.fetch(:voting, nil) || context.fetch(:participatory_space, nil)
        end

        def polling_station
          @polling_station ||= context.fetch(:polling_station, nil)
        end

        def polling_officer
          @polling_officer ||= context.fetch(:polling_officer, nil)
        end

        def monitoring_committee_member
          @monitoring_committee_member ||= context.fetch(:monitoring_committee_member, nil)
        end

        def ballot_style
          @ballot_style ||= context.fetch(:ballot_style, nil)
        end

        def closure
          @closure ||= context.fetch(:closure, nil)
        end

        def election
          @election ||= context.fetch(:election, nil)
        end
      end
    end
  end
end
