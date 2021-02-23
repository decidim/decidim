# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to create or delete a monitoring committee member.
      class MonitoringCommitteeMembersController < Admin::ApplicationController
        include VotingAdmin

        helper_method :current_voting, :monitoring_committee_members, :monitoring_committee_member

        def new
          enforce_permission_to :create, :monitoring_committee_member, voting: current_voting
          @form = form(MonitoringCommitteeMemberForm).instance
        end

        def create
          enforce_permission_to :create, :monitoring_committee_member, voting: current_voting
          @form = form(MonitoringCommitteeMemberForm).from_params(params, voting: current_voting)

          CreateMonitoringCommitteeMember.call(@form, current_user, current_voting) do
            on(:ok) do
              flash[:notice] = I18n.t("monitoring_committee_members.create.success", scope: "decidim.votings.admin")
              redirect_to voting_monitoring_committee_members_path(current_voting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("monitoring_committee_members.create.invalid", scope: "decidim.votings.admin")
              render action: "new"
            end
          end
        end

        def destroy
          enforce_permission_to :delete, :monitoring_committee_member, voting: current_voting, monitoring_committee_member: monitoring_committee_member

          DestroyMonitoringCommitteeMember.call(monitoring_committee_member, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("monitoring_committee_members.destroy.success", scope: "decidim.votings.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("monitoring_committee_members.destroy.invalid", scope: "decidim.votings.admin")
            end
          end

          redirect_to voting_monitoring_committee_members_path(current_voting)
        end

        private

        def monitoring_committee_members
          @monitoring_committee_members ||= current_voting.monitoring_committee_members
        end

        def monitoring_committee_member
          @monitoring_committee_member ||= monitoring_committee_members.find(params[:id])
        end
      end
    end
  end
end
