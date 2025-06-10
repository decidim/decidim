# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessGroupType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:participatory_process_group) }

      include_examples "timestamps interface"

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
          expect(response["heroImage"]).to be_blob_url(model.hero_image.blob)
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

      describe "developerGroup" do
        let(:query) { '{ developerGroup { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["developerGroup"]["translation"]).to eq(model.developer_group["en"])
        end
      end

      describe "metaScope" do
        let(:query) { '{ metaScope { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["metaScope"]["translation"]).to eq(model.meta_scope["en"])
        end
      end

      describe "localArea" do
        let(:query) { '{ localArea { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["localArea"]["translation"]).to eq(model.local_area["en"])
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the process' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "target" do
        let(:query) { '{ target { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["target"]["translation"]).to eq(model.target["en"])
        end
      end

      describe "participatoryScope" do
        let(:query) { '{ participatoryScope { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["participatoryScope"]["translation"]).to eq(model.participatory_scope["en"])
        end
      end

      describe "participatoryStructure" do
        let(:query) { '{ participatoryStructure { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["participatoryStructure"]["translation"]).to eq(model.participatory_structure["en"])
        end
      end
    end
  end
end
