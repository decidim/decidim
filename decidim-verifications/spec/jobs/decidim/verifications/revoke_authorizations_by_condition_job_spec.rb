# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAuthorizationsByConditionJob do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:now) { Time.zone.now }
    let(:prev_week) { Time.zone.today.prev_week }
    let(:prev_month) { Time.zone.today.prev_month }
    let(:prev_year) { Time.zone.today.prev_year }
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
    let(:impersonated_authorizations) do
      Decidim::Verifications::AuthorizationsBeforeDate.new(
        organization:,
        date: now,
        granted: true,
        impersonated_only: true
      ).query
    end
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:user0) { create(:user, :admin, :confirmed, organization:) }
    let(:user1) { create(:user, :admin, :confirmed, organization:) }
    let(:user2) { create(:user, :admin, :confirmed, organization:) }
    let(:user3) { create(:user, :admin, :confirmed, organization:) }
    let(:user4) { create(:user, :admin, :confirmed, organization:) }
    let(:user5) { create(:user, :admin, :confirmed, organization:, managed: true) }

    describe "with 4 organization's granted auths (only 1 impersonated) and 2 ungranted auths created a month ago" do
      let!(:authorization1) { create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user0) }
      let!(:authorization2) { create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user1) }
      let!(:authorization3) { create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user2) }
      let!(:authorization4) { create(:authorization, created_at: prev_month, granted_at: nil, name: Faker::Name.name, user: user3) }
      let!(:authorization5) { create(:authorization, created_at: prev_month, granted_at: nil, name: Faker::Name.name, user: user4) }
      let!(:authorization6) { create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user5) }

      context "when before date is a week ago and impersonated_only" do
        it "does not destroy any ungranted auth" do
          expect do
            subject.perform_now(organization, current_user, prev_week, true)
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroys granted auths. 4 granted (only 1 impersonated) to 3" do
          expect do
            subject.perform_now(organization, current_user, prev_week, true)
          end.to change(granted_authorizations, :count).from(4).to(3)
        end

        it "destroys all impersonated_only auths. 1 to 0" do
          expect do
            subject.perform_now(organization, current_user, prev_week, true)
          end.to change(impersonated_authorizations, :count).from(1).to(0)
        end

        it "total auths are fewer than before. 6 to 5" do
          expect do
            subject.perform_now(organization, current_user, prev_week, true)
          end.to change(all_authorizations, :count).from(6).to(5)
        end

        it "traces the action", versioning: true do
          impersonated_authorizations.find_each do |auth|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:destroy, auth, current_user)
              .and_call_original
          end
          expect { subject.perform_now(organization, current_user, prev_week, true) }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end

      context "when before date is a year ago and impersonated_only" do
        it "does not destroy any ungranted auth" do
          expect do
            subject.perform_now(organization, current_user, prev_year, true)
          end.not_to change(no_granted_authorizations, :count)
        end

        it "does not destroy any granted auths" do
          expect do
            subject.perform_now(organization, current_user, prev_year, true)
          end.not_to change(granted_authorizations, :count)
        end

        it "total auths are the same. 6" do
          expect do
            subject.perform_now(organization, current_user, prev_year, true)
          end.not_to change(all_authorizations, :count)
        end
      end

      context "when before date is a week ago and not impersonated_only" do
        it "does not destroy any ungranted auth" do
          expect do
            subject.perform_now(organization, current_user, prev_week, false)
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroys all granted auths before date. 4 to 0" do
          expect do
            subject.perform_now(organization, current_user, prev_week, false)
          end.to change(granted_authorizations, :count).from(4).to(0)
        end

        it "total auths are fewer than before. 6 to 2" do
          expect do
            subject.perform_now(organization, current_user, prev_week, false)
          end.to change(all_authorizations, :count).from(6).to(2)
        end

        it "traces the action", versioning: true do
          granted_authorizations.find_each do |auth|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:destroy, auth, current_user)
              .and_call_original
          end
          expect { subject.perform_now(organization, current_user, prev_week, false) }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end

        context "with authorization transfers attached to some of the authorizations" do
          let!(:authorization_transfer1) { create(:authorization_transfer, organization:, authorization: authorization1) }
          let!(:authorization_transfer2) { create(:authorization_transfer, organization:, authorization: authorization1) }
          let!(:authorization_transfer3) { create(:authorization_transfer, organization:, authorization: authorization2) }

          before do
            create_list(:authorization_transfer_record, 2, transfer: authorization_transfer1)
            create_list(:authorization_transfer_record, 2, transfer: authorization_transfer2)
            create(:authorization_transfer_record, transfer: authorization_transfer3)
          end

          it "destroys all granted auths" do
            expect do
              subject.perform_now(organization, current_user, prev_week, false)
            end.to change(granted_authorizations, :count).from(4).to(0)
          end

          it "destroys all authorization transfers" do
            expect do
              subject.perform_now(organization, current_user, prev_week, false)
            end.to change(Decidim::AuthorizationTransfer, :count).from(3).to(0)
          end
        end
      end

      context "when before date is a year ago and not impersonated_only" do
        it "does not destroy any ungranted auth" do
          expect do
            subject.perform_now(organization, current_user, prev_year, false)
          end.not_to change(no_granted_authorizations, :count)
        end

        it "does not destroy any granted auths" do
          expect do
            subject.perform_now(organization, current_user, prev_year, false)
          end.not_to change(granted_authorizations, :count)
        end

        it "does not destroy any impersonated auths" do
          expect do
            subject.perform_now(organization, current_user, prev_year, false)
          end.not_to change(impersonated_authorizations, :count)
        end

        it "total auths are the same. 6" do
          expect do
            subject.perform_now(organization, current_user, prev_year, false)
          end.not_to change(all_authorizations, :count)
        end
      end
    end
  end
end
