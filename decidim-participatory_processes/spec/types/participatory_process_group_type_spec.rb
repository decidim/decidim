# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessGroupType, type: :graphql do
      include_context "with a graphql type"

      let(:model) { create(:participatory_process_group) }

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

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image of the process" do
          expect(response["heroImage"]).to eq(model.hero_image.url)
        end
      end

      describe "participatoryProcesses" do
        let!(:process) { create(:participatory_process, participatory_process_group: model) }

        let(:query) { "{ participatoryProcesses { id } }" }

        it "returns all the required fields" do
          process_response = response["participatoryProcesses"].first
          expect(process_response["id"]).to eq(process.id.to_s)
        end
      end
    end
  end
end
