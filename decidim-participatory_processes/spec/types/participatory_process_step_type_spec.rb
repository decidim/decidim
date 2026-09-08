# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessStepType do
      include_context "with a graphql class type"

      let(:process) do
        create(:participatory_process, organization: current_organization)
      end

      let(:model) do
        create(:participatory_process_step, participatory_process: process)
      end

      include_examples "timestamps interface"

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
          expected_keys = (model.title.keys.excluding("machine_translations") + model.title["machine_translations"].keys).sort
          expect(response["title"]["locales"]).to include(*expected_keys)
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { locales translation(locale:"en") } }' }

        it "returns its description" do
          expected_keys = (model.description.keys.excluding("machine_translations") + model.description["machine_translations"].keys).sort
          expect(response["description"]["locales"]).to include(*expected_keys)
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end

        context "when description is nil" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, description: nil)
          end
          let(:query) { "{ description { translation(locale:\"en\") } }" }

          it "returns nil" do
            expect(response["description"]).to be_nil
          end
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the step's start date" do
          expect(response["startDate"]).to eq(model.start_date.to_time.iso8601)
        end

        context "when start_date is nil" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, start_date: nil)
          end
          let(:query) { "{ startDate }" }

          it "returns nil" do
            expect(response["startDate"]).to be_nil
          end
        end
      end

      describe "endDate" do
        let(:query) { "{ endDate }" }

        it "returns the step's end date" do
          expect(response["endDate"]).to eq(model.end_date.to_time.iso8601)
        end

        context "when end_date is nil" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, end_date: nil)
          end
          let(:query) { "{ endDate }" }

          it "returns nil" do
            expect(response["endDate"]).to be_nil
          end
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns its position" do
          expect(response["position"]).to eq(model.position)
        end

        context "when position is left blank" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, position: nil)
          end
          let(:query) { "{ position }" }

          it "is auto-assigned to zero" do
            expect(response["position"]).to eq(0)
          end
        end
      end

      describe "active" do
        let(:query) { "{ active }" }

        it "returns its active" do
          expect(response["active"]).to eq(model.active)
        end

        context "when active is false" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, active: false)
          end

          let(:query) { "{ active }" }

          it "returns false" do
            expect(response["active"]).to be(false)
          end
        end

        context "when active is true" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, active: true)
          end

          let(:query) { "{ active }" }

          it "returns true" do
            expect(response["active"]).to be(true)
          end
        end
      end

      describe "constraints that does not allow nil" do
        let(:query) { "{ id title { translation(locale:\"en\") } participatoryProcess { id } }" }

        it "always returns id" do
          expect(response["id"]).not_to be_nil
          expect(response["id"]).to eq(model.id.to_s)
        end

        it "always returns title" do
          expect(response["title"]).not_to be_nil
          expect(response["title"]["translation"]).not_to be_nil
        end

        it "always returns participatoryProcess" do
          expect(response["participatoryProcess"]).not_to be_nil
          expect(response["participatoryProcess"]["id"]).to eq(process.id.to_s)
        end
      end

      describe "translatable fields" do
        context "when requesting a missing locale" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, title: { "en" => "English Title", "machine_translations" => { "es" => "Título en español" } })
          end
          let(:query) { '{ title { translation(locale:"ca") } }' }

          it "returns nil" do
            expect(response["title"]["translation"]).to be_nil
          end
        end

        context "when steps belong to different processes" do
          let(:other_process) { create(:participatory_process, organization: current_organization) }
          let!(:other_step) { create(:participatory_process_step, participatory_process: other_process, position: 1) }
          let(:model) do
            create(:participatory_process_step, participatory_process: process, position: 1, active: false)
          end

          let(:query) { "{ id participatoryProcess { id } }" }

          it "returns the correct process association" do
            expect(response["id"]).to eq(model.id.to_s)
            expect(response["participatoryProcess"]["id"]).to eq(process.id.to_s)
            expect(response["participatoryProcess"]["id"]).not_to eq(other_process.id.to_s)
          end
        end

        context "when title has empty string value" do
          let(:model) do
            create(:participatory_process_step,
                   participatory_process: process,
                   title: { "en" => "" })
          end
          let(:query) { '{ title { translation(locale:"en") } }' }

          it "returns empty string for title" do
            expect(response["title"]["translation"]).to be_nil
          end
        end

        context "when title has machine translations" do
          let(:model) do
            create(:participatory_process_step, participatory_process: process, title: { "en" => "English Title", "machine_translations" => { "es" => "Título en español" } })
          end
          let(:query) { '{ title { locales translation(locale:"es") } }' }

          it "includes machine translation locales" do
            expect(response["title"]["locales"]).to include("es")
            expect(response["title"]["translation"]).to eq("Título en español")
          end
        end
      end

      describe "multiple steps scenario" do
        let!(:step1) { create(:participatory_process_step, participatory_process: process, position: 1, active: false) }
        let!(:step2) { create(:participatory_process_step, participatory_process: process, position: 2, active: true) }
        let!(:step3) { create(:participatory_process_step, participatory_process: process, position: 3, active: false) }

        context "when querying the active step" do
          let(:model) { step2 }
          let(:query) { "{ id active }" }

          it "correctly identifies and return the id and the step status" do
            expect(response["id"]).to eq(step2.id.to_s)
            expect(response["active"]).to be(true)
          end
        end

        context "when querying steps by position" do
          let(:model) { step1 }
          let(:query) { "{ id position }" }

          it "returns correct id and position" do
            expect(response["id"]).to eq(step1.id.to_s)
            expect(response["position"]).to eq(step1.position)
          end
        end

        context "when querying all fields together" do
          let(:model) { step2 }
          let(:query) { '{ id title { translation(locale:"en") } description { translation(locale:"en") } startDate endDate position active participatoryProcess { id } }' }

          it "returns all fields correctly in a single query" do
            expect(response["id"]).to eq(step2.id.to_s)
            expect(response["title"]["translation"]).to eq(step2.title["en"])
            expect(response["description"]["translation"]).to eq(step2.description["en"])
            expect(response["startDate"]).to eq(step2.start_date.to_time.iso8601)
            expect(response["endDate"]).to eq(step2.end_date.to_time.iso8601)
            expect(response["position"]).to eq(step2.position)
            expect(response["active"]).to eq(step2.active)
            expect(response["participatoryProcess"]["id"]).to eq(process.id.to_s)
          end
        end
      end
    end
  end
end
