# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe RevokeAuthorizations do
    subject { described_class.new(organization, form) }

    let(:organization) { create(:organization, available_authorizations: [name]) }
    let(:name) { "some_method" }
    let(:impersonated_only) { false }
    let(:before_date) { nil }
    let(:current_user) { create(:user, :admin, :confirmed, organization:) }
    let(:params) { { name:, impersonated_only:, before_date: } }
    let(:form) do
      Decidim::Verifications::Admin::RevocationsForm
        .from_params(params)
        .with_context(current_organization: organization, current_user:)
    end

    context "when the form is invalid" do
      let(:name) { "" }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "does not enqueue a job" do
        expect { subject.call }.not_to have_enqueued_job(Decidim::Verifications::RevokeAuthorizationsJob)
      end
    end

    context "when the form is valid" do
      let!(:granted_authorization) { create(:authorization, :granted, name:, user: create(:user, organization:)) }

      it "broadcasts ok with the count of matching authorizations" do
        expect { subject.call }.to broadcast(:ok, 1)
      end

      it "enqueues a RevokeAuthorizationsJob with the form's attributes" do
        expect { subject.call }.to have_enqueued_job(Decidim::Verifications::RevokeAuthorizationsJob)
          .with(organization, current_user, name, impersonated_only, before_date)
      end

      context "when impersonated_only is true and before_date is present" do
        let(:impersonated_only) { true }
        let(:before_date) { Time.zone.today.prev_week }
        let!(:managed_authorization_old) { create(:authorization, :granted, name:, user: create(:user, organization:, managed: true), created_at: Time.zone.today.prev_month) }
        let!(:managed_authorization_recent) { create(:authorization, :granted, name:, user: create(:user, organization:, managed: true), created_at: Time.zone.now) }

        it "broadcasts ok with the count of matching authorizations" do
          expect { subject.call }.to broadcast(:ok, 1)
        end

        it "enqueues a RevokeAuthorizationsJob with the form's attributes" do
          expect { subject.call }.to have_enqueued_job(Decidim::Verifications::RevokeAuthorizationsJob)
            .with(organization, current_user, name, true, before_date)
        end
      end
    end
  end
end
