# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Consultations
    describe ConsultationType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:consultation) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "subtitle" do
        let(:query) { '{ subtitle { translation(locale: "en")}}' }

        it "returns the subtitle field" do
          expect(response["subtitle"]["translation"]).to eq(model.subtitle["en"])
        end
      end

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the consultation' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the consultation was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the consultation was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the consultation was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "startVotingDate" do
        let(:query) { "{ startVotingDate }" }

        it "returns the signature start date of the consultation" do
          expect(response["startVotingDate"]).to eq(model.start_voting_date.to_date.iso8601)
        end
      end

      describe "endVotingDate" do
        let(:query) { "{ endVotingDate }" }

        it "returns when the consultation signature date ends" do
          expect(response["endVotingDate"]).to eq(model.end_voting_date.to_date.iso8601)
        end
      end

      describe "resultsPublishedAt" do
        let(:query) { "{ resultsPublishedAt }" }

        it "returns when the consultation results have been published" do
          expect(response["resultsPublishedAt"]).to be_nil
        end
      end

      describe "introductoryImage" do
        let(:query) { "{ introductoryImage }" }

        it "returns the hero image field" do
          expect(response["introductoryImage"]).to eq(model.attached_uploader(:introductory_image).path)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to eq(model.attached_uploader(:banner_image).path)
        end
      end

      describe "highlightedScope" do
        let(:query) { "{ highlightedScope { id } }" }

        it "has a highlightedScope" do
          expect(response).to include("highlightedScope" => { "id" => model.highlighted_scope.id.to_s })
        end
      end

      describe "introductoryVideoUrl" do
        let(:query) { "{ introductoryVideoUrl }" }

        it "returns the introductoryVideoUrl field" do
          expect(response["introductoryVideoUrl"]).to eq(model.introductory_video_url)
        end
      end

      context "when results are published" do
        let(:model) { create(:consultation, :published_results) }
        let(:query) { "{ resultsPublishedAt }" }

        it "returns when the consultation results have been published" do
          expect(response["resultsPublishedAt"]).to eq(model.results_published_at.to_date.iso8601)
        end
      end
    end
  end
end
