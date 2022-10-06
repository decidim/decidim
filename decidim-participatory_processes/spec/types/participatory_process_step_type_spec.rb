# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessStepType do
      include_context "with a graphql class type"

      let(:process) do
        create(:participatory_process, organization: current_organization)
      end

      let(:model) do
        create(:participatory_process_step, participatory_process: process, cta_path: "#link1")
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns all the required fields" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "process" do
        let(:query) { "{ participatoryProcess { id } }" }

        it "queries the original process" do
          expect(response).to include("participatoryProcess" => { "id" => process.id.to_s })
        end
      end

      describe "title" do
        let(:query) { '{ title { locales translation(locale:"en") } }' }

        it "returns its title" do
          expect(response["title"]["locales"]).to include(*model.title.keys)
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { locales translation(locale:"en") } }' }

        it "returns its description" do
          expect(response["description"]["locales"]).to include(*model.description.keys)
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the step's start date" do
          expect(response["startDate"]).to eq(model.start_date.to_time.iso8601)
        end
      end

      describe "endDate" do
        let(:query) { "{ endDate }" }

        it "returns the step's end date" do
          expect(response["endDate"]).to eq(model.end_date.to_time.iso8601)
        end
      end

      describe "call_to_action_path" do
        let(:query) { "{ callToActionPath }" }

        it "returns the step's call to action path" do
          expect(response["callToActionPath"]).to eq("#link1")
        end
      end

      describe "call_to_action_text" do
        let(:query) { '{ callToActionText { locales translation(locale:"en") } }' }

        it "returns the step's call to action text" do
          expect(response["callToActionText"]["locales"]).to include(*model.cta_text.keys)
          expect(response["callToActionText"]["translation"]).to eq(model.cta_text["en"])
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns its position" do
          expect(response["position"]).to eq(model.position)
        end
      end

      describe "active" do
        let(:query) { "{ active }" }

        it "returns its active" do
          expect(response["active"]).to eq(model.active)
        end
      end
    end
  end
end
