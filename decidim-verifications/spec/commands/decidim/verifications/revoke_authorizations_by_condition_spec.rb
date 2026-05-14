# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAuthorizationsByCondition do
    subject { described_class.new(organization, form) }

    let(:params) do
      {
        impersonated_only:,
        before_date:
      }
    end

    let(:form) do
      Decidim::Verifications::Admin::RevocationsBeforeDateForm
        .from_params(params)
        .with_context(current_user:)
    end

    let(:prev_week) { Time.zone.today.prev_week }
    let(:organization) { create(:organization) }
    let(:impersonated_only) { true }
    let(:before_date) { prev_week }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }

    describe "when creating a revoke by condition authorizations command" do
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

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "enqueues a RevokeAuthorizationsByConditionJob" do
          expect { subject.call }.to have_enqueued_job(RevokeAuthorizationsByConditionJob)
            .with(organization, current_user, before_date, nil)
        end
      end

      context "with all valid params" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "enqueues a RevokeAuthorizationsByConditionJob with impersonated_only" do
          expect { subject.call }.to have_enqueued_job(RevokeAuthorizationsByConditionJob)
            .with(organization, current_user, before_date, true)
        end
      end
    end
  end
end
