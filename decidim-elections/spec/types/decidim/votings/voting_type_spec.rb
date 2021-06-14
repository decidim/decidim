# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Votings
    describe VotingType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:voting) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the voting's slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the voting was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the voting was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the voting's start time" do
          expect(Time.zone.parse(response["startTime"])).to be_within(1.second).of(model.start_time)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the voting's end time" do
          expect(Time.zone.parse(response["endTime"])).to be_within(1.second).of(model.end_time)
        end
      end

      describe "scope" do
        let(:query) { "{ scope { id } }" }

        it "has a scope" do
          expect(response).to include("scope" => { "id" => model.scope.id.to_s })
        end
      end
    end
  end
end
