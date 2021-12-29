# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

require "decidim/core/test/shared_examples/attachable_interface_examples"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:participatory_process, :with_scope) }

      include_examples "attachable interface"
      include_examples "categories container interface"

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

        it "returns the process' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the process' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the process was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the process was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the process was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "subtitle" do
        let(:query) { '{ subtitle { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["subtitle"]["translation"]).to eq(model.subtitle["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "shortDescription" do
        let(:query) { '{ shortDescription { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["shortDescription"]["translation"]).to eq(model.short_description["en"])
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the start date of the process" do
          expect(response["startDate"]).to eq(model.start_date.to_date.iso8601)
        end
      end

      describe "endDate" do
        let(:query) { "{ endDate }" }

        it "returns when the process ends" do
          expect(response["endDate"]).to eq(model.end_date.to_date.iso8601)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image of the process" do
          expect(response["bannerImage"]).to eq(model.attached_uploader(:banner_image).path)
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image of the process" do
          expect(response["heroImage"]).to eq(model.attached_uploader(:hero_image).path)
        end
      end

      describe "promoted" do
        let(:query) { "{ promoted }" }

        it "returns if the process is promoted" do
          expect(response["promoted"]).to be_in([true, false])
          expect(response["promoted"]).to eq(model.promoted)
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

      describe "showMetrics" do
        let(:query) { "{ showMetrics }" }

        it "returns if the process has metrics available" do
          expect(response["showMetrics"]).to be_in([true, false])
          expect(response["showMetrics"]).to eq(model.show_metrics)
        end
      end

      describe "showStatistics" do
        let(:query) { "{ showStatistics }" }

        it "returns if the process has stats available" do
          expect(response["showStatistics"]).to be_in([true, false])
          expect(response["showStatistics"]).to eq(model.show_statistics)
        end
      end

      describe "scopesEnabled" do
        let(:query) { "{ scopesEnabled }" }

        it "returns if the process has scopes enabled" do
          expect(response["scopesEnabled"]).to be_in([true, false])
          expect(response["scopesEnabled"]).to eq(model.scopes_enabled)
        end
      end

      describe "scope" do
        let(:query) { "{ scope { id } }" }

        it "has a scope" do
          expect(response).to include("scope" => { "id" => model.scope.id.to_s })
        end
      end

      describe "announcement" do
        let(:query) { '{ announcement { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["announcement"]["translation"]).to eq(model.announcement["en"])
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the process' reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "steps" do
        let!(:step) { create(:participatory_process_step, participatory_process: model) }

        let(:query) { "{ steps { id } }" }

        it "returns all the required steps" do
          step_response = response["steps"].first
          expect(step_response["id"]).to eq(step.id.to_s)
        end
      end

      describe "participatoryProcessGroup" do
        let!(:group) { create(:participatory_process_group, participatory_processes: [model]) }

        let(:query) { "{ participatoryProcessGroup {  id } }" }

        it "returns all the required participatory process group" do
          expect(response["participatoryProcessGroup"]["id"]).to eq(group.id.to_s)
        end
      end
    end
  end
end
