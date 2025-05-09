# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ParticipatorySpaceType do
      include_context "with a graphql class type"

      let(:model) { create(:participatory_process) }

      describe "title" do
        let(:query) { %[{ title { translation(locale: "en") } }] }

        it "returns the space's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "components" do
        let!(:published_components) do
          create_list(:dummy_component, 2, participatory_space: model, published_at: Time.current)
        end

        let!(:unpublished_components) do
          create_list(:dummy_component, 2, participatory_space: model, published_at: nil)
        end

        let(:query) { %({ components { id } }) }

        it "only displays the published components" do
          component_ids = response["components"].compact.map { |c| c["id"].to_i }

          # Ordered by ID by default.
          expect(component_ids.sort).to eq(published_components.map(&:id))
          expect(component_ids).not_to include(*unpublished_components.map(&:id))
        end
      end

      describe "stats" do
        let(:query) { %({ stats { name { translation(locale: "en") } value } }) }

        before do
          allow(Decidim::ParticipatoryProcesses::ParticipatoryProcessStatsPresenter).to receive(:new)
            .and_return(double(collection: [
                                 { name: "dummies_count_high", data: [0], tooltip_key: "dummies_count_high_tooltip" }
                               ]))
        end

        it "show all the stats for this participatory process" do
          expect(response["stats"]).to include(
            {
              "name" => { "translation" => "Dummies high" },
              "value" => 0
            }
          )
        end
      end

      describe "manifest" do
        let(:query) { %({ manifest { name humanName { single { translation(locale: "en") } plural { translation(locale: "en") } } } }) }

        it "show the manifest information for this participatory process" do
          expect(response["manifest"]).to include(
            "name" => "participatory_processes",
            "humanName" => {
              "single" => { "translation" => "Participatory process" },
              "plural" => { "translation" => "Participatory processes" }
            }
          )
        end
      end
    end
  end
end
