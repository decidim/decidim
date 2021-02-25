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
            polling_officers: permission_polling_officers
          }
        end
        let(:voting) { create(:voting) }
        let(:polling_officers) { [create(:polling_officer, user: user, voting: voting)] }
        let(:permission_polling_officers) { polling_officers }
        let(:permission_action) { Decidim::PermissionAction.new(action) }

        shared_examples "not allowed when a polling officer is not attached to the current user" do
          context "when a polling officer is not attached to a user" do
            let!(:polling_officers) { create_list(:polling_officer, 2) }

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

        describe "view polling officer" do
          let(:action) do
            { scope: :polling_officer_zone, action: :view, subject: :polling_officers }
          end

          it { is_expected.to eq true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end

        describe "view polling station" do
          let(:action) do
            { scope: :polling_officer_zone, action: :view, subject: :polling_station }
          end

          it { is_expected.to eq true }

          it_behaves_like "not allowed when a polling officer is not attached to the current user"
        end
      end
    end
  end
end
