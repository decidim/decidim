# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAuthorizationsJob do
    subject { described_class }

    let(:organization) { create(:organization) }
    let(:name) { "some_method" }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:user0) { create(:user, organization:) }
    let(:user1) { create(:user, organization:) }
    let(:managed_user) { create(:user, organization:, managed: true) }
    let(:prev_week) { Time.zone.today.prev_week }
    let(:prev_month) { Time.zone.today.prev_month }
    let(:all_authorizations_for_method) { Decidim::Verifications::Authorizations.new(organization:, name:).query }
    let(:granted_authorizations_for_method) { Decidim::Verifications::Authorizations.new(organization:, name:, granted: true).query }

    let!(:granted_recent) { create(:authorization, :granted, name:, user: user0, created_at: Time.zone.now) }
    let!(:granted_old) { create(:authorization, :granted, name:, user: user1, created_at: prev_month) }
    let!(:granted_managed) { create(:authorization, :granted, name:, user: managed_user, created_at: Time.zone.now) }
    let!(:pending_for_method) { create(:authorization, :pending, name:, user: create(:user, organization:)) }
    let!(:granted_for_other_method) { create(:authorization, :granted, user: create(:user, organization:)) }

    context "without impersonated_only or before_date" do
      it "destroys all granted authorizations for the given method" do
        expect do
          subject.perform_now(organization, current_user, name, false, nil)
        end.to change(all_authorizations_for_method, :count).from(4).to(1)
      end

      it "does not destroy the pending authorization" do
        subject.perform_now(organization, current_user, name, false, nil)

        expect(Decidim::Authorization.find_by(id: pending_for_method.id)).to be_present
      end

      it "does not destroy authorizations of other methods" do
        subject.perform_now(organization, current_user, name, false, nil)

        expect(Decidim::Authorization.find_by(id: granted_for_other_method.id)).to be_present
      end

      it "traces the action", versioning: true do
        granted_authorizations_for_method.find_each do |auth|
          expect(Decidim.traceability)
            .to receive(:perform_action!)
            .with(:destroy, auth, current_user)
            .and_call_original
        end

        expect { subject.perform_now(organization, current_user, name, false, nil) }.to change(Decidim::ActionLog, :count).by(3)

        expect(Decidim::ActionLog.last.version).to be_present
      end

      context "with a granted authorization in another organization" do
        let(:other_organization) { create(:organization) }
        let!(:other_organization_authorization) { create(:authorization, :granted, name:, user: create(:user, organization: other_organization)) }

        it "does not destroy the authorization from the other organization" do
          subject.perform_now(organization, current_user, name, false, nil)

          expect(Decidim::Authorization.find_by(id: other_organization_authorization.id)).to be_present
        end
      end
    end

    context "with impersonated_only" do
      it "only destroys the managed user's authorization" do
        expect do
          subject.perform_now(organization, current_user, name, true, nil)
        end.to change(all_authorizations_for_method, :count).from(4).to(3)

        expect(Decidim::Authorization.find_by(id: granted_managed.id)).to be_nil
        expect(Decidim::Authorization.find_by(id: granted_recent.id)).to be_present
      end
    end

    context "with before_date" do
      it "only destroys authorizations created before the given date" do
        expect do
          subject.perform_now(organization, current_user, name, false, prev_week)
        end.to change(all_authorizations_for_method, :count).from(4).to(3)

        expect(Decidim::Authorization.find_by(id: granted_old.id)).to be_nil
        expect(Decidim::Authorization.find_by(id: granted_recent.id)).to be_present
      end
    end

    context "with authorization transfers attached" do
      let!(:authorization_transfer) { create(:authorization_transfer, organization:, authorization: granted_recent) }

      before do
        create_list(:authorization_transfer_record, 2, transfer: authorization_transfer)
      end

      it "destroys the associated authorization transfers" do
        expect do
          subject.perform_now(organization, current_user, name, false, nil)
        end.to change(Decidim::AuthorizationTransfer, :count).from(1).to(0)
      end
    end
  end
end
