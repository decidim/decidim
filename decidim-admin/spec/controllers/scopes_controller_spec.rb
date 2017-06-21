# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe ScopesController, type: :controller do
      let(:organization) { create(:organization) }
      let!(:scopes) do
        %w(Aaaa Aabb Bbbb).map { |name| create(:scope, name: Decidim::Faker::Localized.literal(name), organization: organization) }
      end
      let!(:subscope) { create(:subscope, name: Decidim::Faker::Localized.literal("Cccc"), parent: scopes.first) }

      let(:user) { create(:user, :admin, :confirmed, organization: organization) }
      let(:query) { "" }
      let(:results) { JSON.parse(response.body) }

      before do
        @request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
        get :search, format: :json, params: { term: query }
      end

      context "basic search works" do
        it "request returns OK" do
          expect(response).to be_success
        end

        it "result has id" do
          expect(results["results"].first).to have_key("id")
        end

        it "result has text" do
          expect(results["results"].first).to have_key("text")
        end
      end

      context "search top scopes" do
        it { expect(results["results"].count).to eq(3) }
      end

      context "find one result" do
        let(:query) { "Bb" }
        it { expect(results["results"].count).to eq(1) }
      end

      context "find several results" do
        let(:query) { "Aa" }
        it { expect(results["results"].count).to eq(2) }
      end

      context "find subscopes" do
        let(:query) { "Cc" }
        it { expect(results["results"].count).to eq(1) }
      end

      context "don't find results" do
        let(:query) { "Dd" }
        it { expect(results["results"].count).to eq(0) }
      end
    end
  end
end
