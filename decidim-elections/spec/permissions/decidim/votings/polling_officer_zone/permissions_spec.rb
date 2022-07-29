# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module PollingOfficerZone
      describe Permissions do
        subject { described_class.new(user, permission_action, context).permissions.allowed? }

        let(:user) { create :user, organization: voting.organization }
        let(:context) do
          {
            polling_officer:,
            polling_officers:
          }
        end
        let(:voting) { create(:voting) }
        let(:other_voting) { create(:voting, organization: voting.organization) }
        let(:polling_officer) { create(:polling_officer, user:, voting:) }
        let(:polling_officers) { [polling_officer, create(:polling_officer, user:, voting: other_voting)] }
        let(:polling_station) { create(:polling_station, voting:) }
        let(:closure) { create :ps_closure, polling_officer:, polling_station: }
        let(:permission_action) { Decidim::PermissionAction.new(**action) }

        shared_examples "not allowed when a polling officer is not attached to the current user" do
          context "when a polling officer is not attached to a user" do
            let!(:polling_officer) { create(:polling_officer, voting:) }

            it { is_expected.to be_falsey }
          end
        end

        context "when scope is not polling officer zone" do
          let(:action) do
            { scope: :foo, action: :bar, subject: :polling_officers }
          end

          it_behaves_like "permission is not set"
        end

        context "when subject is not correct" do
          let(:action) do
            { scope: :polling_officer_zone, action: :view, subject: :foo }
          end

          it_behaves_like "permission is not set"
        end

        context "when action is not correct" do
          let(:action) do
            { scope: :polling_officer_zone, action: :foo, subject: :polling_officers }
          end

          it_behaves_like "permission is not set"
        end

        describe "view polling officers" do
          let(:action) do
            { scope: :polling_officer_zone, action: :view, subject: :polling_officers }
          end

          it { is_expected.to be true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end

        describe "manage polling station results" do
          let(:action) do
            { scope: :polling_officer_zone, action: :manage, subject: :polling_station_results }
          end

          it { is_expected.to be true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end

        describe "create polling station results" do
          let(:action) do
            { scope: :polling_officer_zone, action: :create, subject: :polling_station_results }
          end

          it { is_expected.to be true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end

        describe "edit polling station results" do
          let(:action) do
            { scope: :polling_officer_zone, action: :edit, subject: :polling_station_results }
          end
          let(:context) do
            { polling_officer:, closure: }
          end
          let(:polling_officer) { create(:polling_officer, :president, user:, voting:) }

          it { is_expected.to be true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"

          context "when there's no closure" do
            let(:context) do
              { polling_officer: }
            end

            it { is_expected.to be false }
          end

          context "and closure is sealed" do
            let(:closure) { create :ps_closure, :completed, polling_officer:, polling_station: }

            it { is_expected.to be false }
          end
        end

        describe "manage in person votes" do
          let(:action) do
            { scope: :polling_officer_zone, action: :manage, subject: :in_person_vote }
          end

          it { is_expected.to be true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end
      end
    end
  end
end
