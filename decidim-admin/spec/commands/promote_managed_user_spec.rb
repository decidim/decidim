# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe PromoteManagedUser do
    subject { described_class.new(form, user, current_user) }

    let(:organization) { create :organization }
    let!(:current_user) { create :user, :admin, organization: organization }
    let(:email) { "foo@example.org" }
    let(:form_params) do
      {
        email: email
      }
    end
    let(:form) do
      ManagedUserPromotionForm.from_params(
        form_params
      ).with_context(
        current_organization: organization
      )
    end
    let!(:user) { create :user, :managed, organization: organization }

    context "when everything is ok" do
      before do
        clear_enqueued_jobs
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "user is invited to the application" do
        subject.call
        expect(user.reload.email).to eq(form.email)
        expect(ActionMailer::DeliveryJob).to have_been_enqueued.on_queue("mailers")
      end
    end

    context "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the user is not managed" do
      let(:user) { create :user, organization: organization }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the email address already exists" do
      let!(:other_user) { create(:user, email: email, organization: organization) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
