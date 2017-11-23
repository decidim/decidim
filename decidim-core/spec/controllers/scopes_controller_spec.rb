# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ScopesController, type: :controller do
    routes { Decidim::Core::Engine.routes }

    subject { results["results"] }

    let(:organization) { create(:organization) }
    let!(:scopes) do
      %w(Aaaa Aabb Bbbb).map { |name| create(:scope, name: Decidim::Faker::Localized.literal(name), organization: organization) }
    end
    let!(:subscope) { create(:subscope, name: Decidim::Faker::Localized.literal("Cccc"), parent: scopes.first) }

    let(:user) { create(:user, :admin, :confirmed, organization: organization) }
    let(:query) { "" }
    let(:params) { { term: query } }
    let(:results) { JSON.parse(response.body) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user, scope: :user
      get :search, format: :json, params: params
    end

    matcher :have_scopes do |expected|
      match do |results|
        result_texts = results.map { |r| r["text"] }

        RSpec::Matchers::BuiltIn::ContainExactly.new(result_texts).matches?(expected)
      end
    end

    describe "basic search" do
      it "request returns OK" do
        expect(response).to be_success
      end

      it "result has id" do
        expect(subject.first).to have_key("id")
      end

      it "result has text" do
        expect(subject.first).to have_key("text")
      end
    end

    describe "search top scopes" do
      it { is_expected.to have_scopes %w(Aaaa Aabb Bbbb) }
    end

    context "when one result" do
      let(:query) { "Bb" }

      it { is_expected.to have_scopes %w(Bbbb) }
    end

    context "when several results" do
      let(:query) { "Aa" }

      it { is_expected.to have_scopes %w(Aaaa Aabb) }
    end

    context "when subscopes" do
      let(:query) { "Cc" }

      it { is_expected.to have_scopes %w(Cccc) }
    end

    context "when no results" do
      let(:query) { "Dd" }

      it { is_expected.to be_empty }
    end

    context "with root filter" do
      let(:params) { { term: query, root: scopes.first } }

      it { is_expected.to have_scopes %w(Cccc) }

      context "with one result" do
        let(:query) { "Cc" }

        it { is_expected.to have_scopes %w(Cccc) }
      end

      context "without results outside the root scope" do
        let(:query) { "Bb" }

        it { is_expected.to be_empty }
      end

      context "when including root" do
        let(:params) { { term: query, root: scopes.first, include_root: true } }

        it { is_expected.to have_scopes %w(Aaaa Cccc) }
      end
    end
  end
end
