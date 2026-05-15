# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAllAuthorizations do
    subject { described_class.new(organization, current_user) }

    let(:organization) { create(:organization) }
    let!(:current_user) { create(:user, :admin, :confirmed, organization:) }

    describe "When creating a revoke all authorizations command" do
      context "with organization not set" do
        subject { described_class.new(nil, current_user) }

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "does not enqueue a job" do
          expect { subject.call }.not_to have_enqueued_job(RevokeAllAuthorizationsJob)
        end
      end

      context "with valid organization" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "enqueues a RevokeAllAuthorizationsJob" do
          expect { subject.call }.to have_enqueued_job(RevokeAllAuthorizationsJob).with(organization, current_user)
        end
      end
    end
  end
end
