# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe ParticipatorySpaceType do
      include_context "with a graphql type"

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

        it "only includes the published components" do
          component_ids = response["components"].map { |c| c["id"].to_i }

          expect(component_ids).to include(*published_components.map(&:id))
          expect(component_ids).not_to include(*unpublished_components.map(&:id))
        end
      end

      describe "stats" do
        let(:query) { %({ stats { name value } }) }

        it "show all the stats for this participatory process" do
          expect(response["stats"]).to include("name" => "dummies_count_high", "value" => 0)
        end
      end
    end
  end
end
