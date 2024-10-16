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
        resource: component
      )
    end

    let(:token) { "ABC123" }
    let(:automatic_token) { true }
    let(:expires_at) { Time.zone.today + 3.days }
    let(:no_expiration) { false }
    let(:registered_only) { true }

    it "returns defaults" do
      expect(form.token).to eq("ABC123")
      expect(form.automatic_token).to be(true)
      expect(form.expires_at).to eq(Time.zone.today + 3.days)
      expect(form.no_expiration).to be(false)
      expect(form.registered_only).to be(true)
    end

    context "when automatic_token validation is false" do
      let(:automatic_token) { false }

      it "validates presence of token" do
        form.token = nil
        expect(form).to be_invalid
        expect(form.errors[:token]).to include("cannot be blank")
      end

      context "when automatic_token is set" do
        let(:token) { "" }
        let(:automatic_token) { true }

        it "does not validate presence of token" do
          expect(form).to be_valid
        end
      end
    end

    context "when expires_at is nil" do
      let(:expires_at) { nil }

      it "validates presence of expires_at" do
        expect(form).to be_invalid
        expect(form.errors[:expires_at]).to include("cannot be blank")
      end

      context "when no_expiration is set" do
        let(:no_expiration) { true }

        it "does not expires" do
          expect(form).to be_valid
        end
      end
    end

    context "when token is custom" do
      let(:token) { "abc 123 " }

      it "returns the token in uppercase" do
        expect(form.token).to eq("ABC-123")
      end

      context "and has strange characters" do
        let(:token) { "abc 123 !@#$%^&*()_+" }

        it "returns the token in uppercase" do
          expect(form).to be_invalid
          expect(form.errors[:token]).to include("is invalid")
        end
      end
    end

    context "when token exists" do
      let(:automatic_token) { false }
      let!(:share_token) { create(:share_token, organization:, token_for: component, token:) }

      it "validates uniqueness of token" do
        expect(form).to be_invalid
        expect(form.errors[:token]).to include("has already been taken")
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
