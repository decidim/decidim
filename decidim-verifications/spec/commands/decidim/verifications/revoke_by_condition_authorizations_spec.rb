# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeByConditionAuthorizations do
    subject { described_class.new(organization, current_user, form) }

    let(:params) do
      {
        impersonated_only:,
        before_date:
      }
    end
    let(:form) do
      Decidim::Verifications::Admin::RevocationsBeforeDateForm.from_params(params)
    end
    let(:now) { Time.zone.now }
    let(:prev_week) { Time.zone.today.prev_week }
    let(:prev_month) { Time.zone.today.prev_month }
    let(:prev_year) { Time.zone.today.prev_year }
    let(:organization) { create(:organization) }
    let(:impersonated_only) { true }
    let(:before_date) { prev_week }
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

    describe "when creating a revoke all authorizations command" do
      context "with organization not set neither current_user but impersonated_only & before_date" do
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

    describe "with 4 organization's granted auths (only 1 impersonated) and 2 ungranted auths created a month ago." do
      before do
        create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user0)
        create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user1)
        create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user2)
        create(:authorization, created_at: prev_month, granted_at: nil, name: Faker::Name.name, user: user3)
        create(:authorization, created_at: prev_month, granted_at: nil, name: Faker::Name.name, user: user4)
        create(:authorization, created_at: prev_month, granted_at: prev_month, name: Faker::Name.name, user: user5)
      end

      context "when no before date. When destroy impersonated_only auths" do
        let(:before_date) { nil }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when no before date. When destroy all auths" do
        let(:before_date) { nil }
        let(:impersonated_only) { nil }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when before date, week ago. When destroy impersonated_only auths" do
        it "doesn't destroy any ungranted auth" do
          expect do
            subject.call
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroy granted auths. 4 granted (only 1 impersonated) to 3" do
          expect do
            subject.call
          end.to change(granted_authorizations, :count).from(4).to(3)
        end

        it "destroy all impersonated_only auths. 1 to 0" do
          expect do
            subject.call
          end.to change(impersonated_authorizations, :count).from(1).to(0)
        end

        it "total auths are fewer than before. 6 to 5" do
          expect do
            subject.call
          end.to change(all_authorizations, :count).from(6).to(5)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "traces the action", versioning: true do
          impersonated_authorizations.find_each do |auth|
            expect(Decidim.traceability)
              .to receive(:perform_action!)
              .with(:destroy, auth, current_user)
              .and_call_original
          end
          expect { subject.call }.to change(Decidim::ActionLog, :count)
          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
        end
      end

      context "when before date, year ago. When destroy impersonated_only auths" do
        let(:before_date) { prev_year }

        it "doesn't destroy any ungranted auth. None" do
          expect do
            subject.call
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroy all impersonated_only auths before_date only. None" do
          expect do
            subject.call
          end.not_to change(granted_authorizations, :count)
        end

        it "total auths are the same than before. 6" do
          expect do
            subject.call
          end.not_to change(all_authorizations, :count)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end
      end

      context "when before date, week ago. When destroy all auths" do
        let(:impersonated_only) { nil }

        it "destroy all ungranted auth. None" do
          expect do
            subject.call
          end.not_to change(no_granted_authorizations, :count)
        end

        it "destroy all granted auths before_date only. 4 to 0" do
          expect do
            subject.call
          end.to change(granted_authorizations, :count).from(4).to(0)
        end

        it "total auths are fewer than before. 6 to 2" do
          expect do
            subject.call
          end.to change(all_authorizations, :count).from(6).to(2)
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
      end

      context "when before date, year ago. When destroy all auths" do
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

        it "destroy impersonated_only auths before_date only. None" do
          expect do
            subject.call
          end.not_to change(impersonated_authorizations, :count)
        end

        it "total auths are the same than before. 6" do
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
