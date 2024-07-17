# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe ShareTokenForm do
    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :admin, organization:) }
    let(:component) { create(:component, participatory_space: create(:participatory_process, organization:)) }

    let(:form) do
      described_class.from_params(
        token:,
        automatic_token:,
        expires_at:,
        no_expiration:,
        registered_only:
      ).with_context(
        current_user:,
        current_organization: organization,
        component:
      )
    end

    let(:token) { "ABC123" }
    let(:automatic_token) { false }
    let(:expires_at) { Time.zone.today + 3.days }
    let(:no_expiration) { false }
    let(:registered_only) { true }

    it "returns registered only true" do
      expect(form.registered_only).to be(true)
    end

    context "when automatic_token validation is false" do
      let(:automatic_token) { false }

      it "validates presence of token" do
        form.token = nil
        expect(form).to be_invalid
        expect(form.errors[:token]).to include("cannot be blank")
      end
    end

    context "when expires_at is nil" do
      let!(:expires_at) { nil }

      it "does not expires" do
        expect(form).to be_valid
      end
    end

    context "when token is custom" do
      it "returns the token in uppercase" do
        form.token = "abc123"
        expect(form.token).to eq("ABC123")
      end
    end

    describe "#token_for" do
      it "returns the component from the context" do
        expect(form.token_for).to eq(component)
      end
    end

    describe "#organization" do
      it "returns the current organization from the context" do
        expect(form.organization).to eq(organization)
      end
    end

    describe "#user" do
      it "returns the current user from the context" do
        expect(form.user).to eq(current_user)
      end
    end
  end
end
