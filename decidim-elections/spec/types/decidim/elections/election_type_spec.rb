# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/traceable_interface_examples"

module Decidim
  module Elections
    describe ElectionType, type: :graphql do
      include_context "with a graphql type"

      let(:election) { create(:election) }

      include_examples "traceable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => election.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["title"]["translation"]).to eq(election.title["en"])
        end
      end

      describe "subtitle" do
        let(:query) { '{ subtitle { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["subtitle"]["translation"]).to eq(election.subtitle["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(election.description["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the election's start time" do
          expect(Time.zone.parse(response["startTime"])).to be_within(1.second).of(election.start_time)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the election's end time" do
          expect(Time.zone.parse(response["endTime"])).to be_within(1.second).of(election.end_time)
        end
      end
    end
  end
end
