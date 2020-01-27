# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  module Decidim::Verifications
    describe RevokeAllAuthorizations do
      subject { described_class.new(organization, current_user) }
      let(:organization) { create(:organization) }
      let(:now) { DateTime.now }
      let(:prev_week) { Date.today.prev_week }
      let(:all_authorizations) {
        Decidim::Verifications::Authorizations.new(
          organization: organization,
        ).query
      }
      let(:granted_authorizations) {
        Decidim::Verifications::Authorizations.new(
          organization: organization,
          granted: true
        ).query
      }
      let(:no_granted_authorizations) {
        Decidim::Verifications::Authorizations.new(
          organization: organization,
          granted: false
        ).query
      }
      let!(:current_user) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:user0) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:user1) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:user2) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:user3) { create(:user, :admin, :confirmed, organization: organization) }
      let!(:user4) { create(:user, :admin, :confirmed, organization: organization) }

      # With 5 authorizations, 3 granted, 2 pending
      before do
        3.times { |index|
          Decidim::Authorization.create!(
            name: Faker::Name.name,
            metadata: nil,
            decidim_user_id: eval("user#{index}").id,
            created_at: prev_week,
            updated_at: now,
            unique_id: nil,
            granted_at: prev_week,
            verification_metadata: nil
        )}
        2.times { |index|
          Decidim::Authorization.create!(
            name: Faker::Name.name,
            metadata: nil,
            decidim_user_id: eval("user#{index + 3}").id,
            created_at: prev_week,
            updated_at: now,
            unique_id: nil,
            granted_at: nil,
            verification_metadata: nil
        )}
      end

      # Decidim::Verifications::Admin::RevocationsBeforeDateForm.from_params(params)
      # let(:form) { RevocationsBeforeDateForm.from_params(params).with_context(context) }
      # let(:command) { described_class.new(form) }

      describe "When creating a revoke all authorizations command" do
        context "with organization not set" do
          let(:subject) { described_class.new(nil, current_user) }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end

      describe "With 3 organization's granted auths and 2 ungranted auths" do
        context "when destroy all granted auths" do
          it "doesn't destroy any ungranted auth" do
            expect do
              subject.call
            end.not_to change(no_granted_authorizations, :count)
          end
          it "destroy all granted auths" do
            expect do
              subject.call
            end.to change{ granted_authorizations.count }.from(3).to(0)
          end
          it "total auths are fewer than before" do
            expect do
              subject.call
            end.to change{ all_authorizations.count }.from(5).to(2)
          end
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
          it "traces the action", versioning: true do
            granted_authorizations.to_a.each { |auth|
              expect(Decidim.traceability)
                .to receive(:perform_action!)
                .with(:delete, auth, current_user)
                .and_call_original
            }
            expect { subject.call }.to change(Decidim::ActionLog, :count)
            action_log = Decidim::ActionLog.last
            expect(action_log.version).to be_present
          end
        end
      end
    end
  end
end
