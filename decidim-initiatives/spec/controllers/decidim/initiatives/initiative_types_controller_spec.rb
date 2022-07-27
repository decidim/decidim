# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe InitiativeTypesController, type: :controller do
      routes { Decidim::Initiatives::Engine.routes }

      subject { results["results"] }

      let(:organization) { create(:organization) }
      let!(:initiative_types) do
        %w(Aaaa Aabb Bbbb).map do |title|
          create(:initiatives_type,
                 title: Decidim::Faker::Localized.literal(title),
                 description: Decidim::Faker::Localized.sentence(word_count: 25),
                 organization:)
        end
      end

      let(:user) { create(:user, :admin, :confirmed, organization:) }
      let(:query) { "" }
      let(:params) { { term: query } }
      let(:results) { JSON.parse(response.body) }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
        get :search, format: :json, params:
      end

      matcher :have_initiative_types do |expected|
        match do |results|
          result_texts = results.map { |r| r["text"] }

          RSpec::Matchers::BuiltIn::ContainExactly.new(result_texts).matches?(expected)
        end
      end

      context "when basic search works" do
        it "request returns OK" do
          expect(response).to be_successful
        end

        it "result has id" do
          expect(subject.first).to have_key("id")
        end

        it "result has text" do
          expect(subject.first).to have_key("text")
        end

        it "doesn't store the location for user" do
          expect(controller.stored_location_for(user)).to be_nil
        end
      end

      context "when find one result" do
        let(:query) { "Bb" }

        it { is_expected.to have_initiative_types %w(Bbbb) }
      end

      context "when find several results" do
        let(:query) { "Aa" }

        it { is_expected.to have_initiative_types %w(Aaaa Aabb) }
      end

      context "when don't find results" do
        let(:query) { "Dd" }

        it { is_expected.to be_empty }
      end
    end
  end
end
