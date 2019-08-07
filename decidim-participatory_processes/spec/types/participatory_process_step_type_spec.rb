# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessStepType do
      include_context "with a graphql type"

      let(:process) do
        create(:participatory_process, organization: current_organization)
      end

      let(:model) do
        create(:participatory_process_step, participatory_process: process)
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
        let(:query) { "{ title { locales } }" }

        it "returns its title" do
          expect(response["title"]["locales"]).to include(*process.title.keys)
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the step's start date" do
          expect(response["startDate"]).to eq(model.start_date.to_date.iso8601)
        end
      end
    end
  end
end
