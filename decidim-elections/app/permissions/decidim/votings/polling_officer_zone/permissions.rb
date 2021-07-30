# frozen_string_literal: true

module Decidim
  module Votings
    module PollingOfficerZone
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless permission_action.scope == :polling_officer_zone

          case permission_action.subject
          when :polling_officers
            toggle_allow(polling_officers_for_user?) if permission_action.action == :view
          when :polling_station_results, :in_person_vote
            toggle_allow(polling_officer.user == user) if permission_action.action == :manage
          when :user
            allow! if permission_action.action == :update_profile
          end

          permission_action
        end

        private

        def polling_officers_for_user?
          polling_officers.any? && polling_officers.all? { |polling_officer| polling_officer.user == user }
        end

        def polling_officers
          @polling_officers ||= context.fetch(:polling_officers, [])
        end

        def polling_officer
          @polling_officer ||= context.fetch(:polling_officer, [])
        end
      end
    end
  end
end
