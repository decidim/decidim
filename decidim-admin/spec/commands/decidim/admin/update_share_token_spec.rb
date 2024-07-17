# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateShareToken do
    subject { described_class.new(form, share_token) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, organization:) }
    let(:component) { create(:component, participatory_space: create(:participatory_process, organization:)) }
    let!(:share_token) { create(:share_token, organization:, user:, token_for: component) }

    let(:form) do
      ShareTokenForm.from_params(
        token:,
        expires_at:,
        automatic_token:,
        no_expiration:,
        registered_only:
      ).with_context(
        current_user: user,
        current_organization: organization,
        component:
      )
    end

    let(:token) { "ABCDEF97765544" }
    let(:expires_at) { Time.zone.today + 20.days }
    let(:automatic_token) { false }
    let(:no_expiration) { false }
    let(:registered_only) { false }

    context "when the form is valid" do
      it "updates the expiration date" do
        expect { subject.call }.to change { share_token.reload.expires_at }.to(expires_at)
                                                                           .and change { share_token.reload.registered_only }.to(registered_only)
      end

      it "broadcasts :ok with the resource" do
        expect(subject).to receive(:broadcast).with(:ok, share_token)
        subject.call
      end
    end

    context "when the form is invalid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "does not update the share token" do
        expect { subject.call }.not_to(change { share_token.reload.attributes })
      end

      it "broadcasts :invalid" do
        expect(subject).to receive(:broadcast).with(:invalid)
        subject.call
      end
    end
  end
end
