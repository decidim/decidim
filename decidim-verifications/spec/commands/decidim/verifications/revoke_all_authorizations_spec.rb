# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAllAuthorizations do
    subject { described_class.new(organization, current_user) }

    let(:organization) { create(:organization) }
    let(:now) { Time.zone.now }
    let(:prev_week) { Time.zone.today.prev_week }
    let(:all_authorizations) do
      Decidim::Verifications::Authorizations.new(
        organization:
      ).query
    end
    let(:granted_authorizations) do
      Decidim::Verifications::Authorizations.new(
        organization:,
        granted: true
      ).query
    end
    let(:no_granted_authorizations) do
      Decidim::Verifications::Authorizations.new(
        organization:,
        granted: false
      ).query
    end
    let!(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let!(:user0) { create(:user, :admin, :confirmed, organization:) }
    let!(:user1) { create(:user, :admin, :confirmed, organization:) }
    let!(:user2) { create(:user, :admin, :confirmed, organization:) }
    let!(:user3) { create(:user, :admin, :confirmed, organization:) }
    let!(:user4) { create(:user, :admin, :confirmed, organization:) }
    let!(:user5) { create(:user, :admin, :confirmed, organization:, managed: true) }

    # With 6 authorizations, 3 granted, 2 pending, only 1 granted & managed
    let!(:authorization1) { create(:authorization, created_at: prev_week, granted_at: prev_week, name: Faker::Name.name, user: user0) }
    let!(:authorization2) { create(:authorization, created_at: prev_week, granted_at: prev_week, name: Faker::Name.name, user: user1) }
    let!(:authorization3) { create(:authorization, created_at: prev_week, granted_at: prev_week, name: Faker::Name.name, user: user2) }
    let!(:authorization4) { create(:authorization, created_at: prev_week, granted_at: nil, name: Faker::Name.name, user: user3) }
    let!(:authorization5) { create(:authorization, created_at: prev_week, granted_at: nil, name: Faker::Name.name, user: user4) }
    let!(:authorization6) { create(:authorization, created_at: prev_week, granted_at: prev_week, name: Faker::Name.name, user: user5) }

    describe "When creating a revoke all authorizations command" do
      context "with organization not set" do
        subject { described_class.new(nil, current_user) }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    describe "With 4 granted auths and 2 ungranted auths" do
      context "when destroy all granted auths" do
        it "does not destroy any ungranted auth" do
          expect do
            subject.call
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroy all granted auths" do
          expect do
            subject.call
          end.to change(granted_authorizations, :count).from(4).to(0)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "traces the action", versioning: true do
          granted_authorizations.find_each do |auth|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:destroy, auth, current_user)
              .and_call_original
          end
          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        context "with authorization transfers attached to some of the authorizations" do
          let!(:authorization_trasfer1) { create(:authorization_transfer, organization:, authorization: authorization1) }
          let!(:authorization_trasfer2) { create(:authorization_transfer, organization:, authorization: authorization1) }
          let!(:authorization_trasfer3) { create(:authorization_transfer, organization:, authorization: authorization2) }

          before do
            create_list(:authorization_transfer_record, 2, transfer: authorization_trasfer1)
            create_list(:authorization_transfer_record, 2, transfer: authorization_trasfer2)
            create(:authorization_transfer_record, transfer: authorization_trasfer3)
          end

          it "destroy all granted auths" do
            expect do
              subject.call
            end.to change(granted_authorizations, :count).from(4).to(0)
          end

          it "destroy all authorization transfers" do
            expect do
              subject.call
            end.to change(Decidim::AuthorizationTransfer, :count).from(3).to(0)
          end
        end
      end
    end
  end
end
