# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  module Decidim::Verifications
    describe RevokeByConditionAuthorizations do
      subject { described_class.new(organization, current_user, before_date, impersonated_only) }

      let(:now) { DateTime.now }
      let(:prev_week) { Date.today.prev_week }
      let(:prev_month) { Date.today.prev_month }
      let(:prev_year) { Date.today.prev_year }
      let(:organization) { create(:organization) }
      let(:impersonated_only) { true }
      let(:before_date) { prev_week }
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
      let(:current_user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user0) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user1) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user2) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user3) { create(:user, :admin, :confirmed, organization: organization) }
      let(:user4) { create(:user, :admin, :confirmed, organization: organization) }

      describe "When creating a revoke all authorizations command" do
        context "with organization not set but impersonated_only & before_date" do
          let(:organization) { nil }
          let(:current_user) { nil }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
        context "with organization set but no impersonated_only neither before_date" do
          let(:impersonated_only) { nil }
          let(:before_date) { nil }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
        context "with organization & impersonated_only set but no before_date" do
          let(:before_date) { nil }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
        context "with organization & before_date but no impersonated_only" do
          let(:impersonated_only) { nil }
          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end

      describe "With 3 organization's granted auths and 2 ungranted auths a month ago." do
        before do
          3.times { |index|
            Decidim::Authorization.create!(
              name: Faker::Name.name,
              metadata: nil,
              decidim_user_id: eval("user#{index}").id,
              created_at: prev_month,
              updated_at: now,
              unique_id: nil,
              granted_at: prev_month,
              verification_metadata: nil
          )}
          2.times { |index|
            Decidim::Authorization.create!(
              name: Faker::Name.name,
              metadata: nil,
              decidim_user_id: eval("user#{index + 3}").id,
              created_at: prev_month,
              updated_at: now,
              unique_id: nil,
              granted_at: nil,
              verification_metadata: nil
          )}
        end

        context "No before date. When destroy impersonated_only auths" do
          let(:before_date) { nil }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "No before date. When destroy all auths" do
          let(:before_date) { nil }
          let(:impersonated_only) { nil }
          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "Before date, week ago. When destroy impersonated_only auths" do
          it "doesn't destroy any ungranted auth" do
            expect do
              subject.call
            end.not_to change(no_granted_authorizations, :count)
          end
          it "destroy all granted auths. 3 to 0" do
            expect do
              subject.call
            end.to change{ granted_authorizations.count }.from(3).to(0)
          end
          it "total auths are fewer than before. 5 to 2" do
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

        context "Before date, year ago. When destroy impersonated_only auths" do
          let(:before_date) { prev_year }
          it "doesn't destroy any ungranted auth. None" do
            expect do
              subject.call
            end.not_to change(no_granted_authorizations, :count)
          end
          it "destroy all granted auths before_date only. None" do
            expect do
              subject.call
            end.not_to change(granted_authorizations, :count)
          end
          it "total auths are the same than before. 5" do
            expect do
              subject.call
            end.not_to change(all_authorizations, :count)
          end
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end

        context "Before date, week ago. When destroy all auths" do
          let(:impersonated_only) { nil }
          it "destroy all ungranted auth" do
            expect do
              subject.call
            end.not_to change(no_granted_authorizations, :count)
          end
          it "destroy all granted auths before_date only. 3 to 0" do
            expect do
              subject.call
            end.to change{ granted_authorizations.count }.from(3).to(0)
          end
          it "total auths are fewer than before. 5 to 2" do
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

        context "Before date, year ago. When destroy all auths" do
          let(:before_date) { prev_year }
          let(:impersonated_only) { nil }
          it "destroy all ungranted auth before date. None" do
            expect do
              subject.call
            end.not_to change(no_granted_authorizations, :count)
          end
          it "destroy all granted auths before_date only. None" do
            expect do
              subject.call
            end.not_to change(granted_authorizations, :count)
          end
          it "total auths are the same than before. 5" do
            expect do
              subject.call
            end.not_to change(all_authorizations, :count)
          end
          it "broadcasts ok" do
            expect { subject.call }.to broadcast(:ok)
          end
        end
      end
    end
  end
end
