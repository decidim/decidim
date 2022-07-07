# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

require "decidim/core/test/shared_examples/attachable_interface_examples"

module Decidim
  module Conferences
    describe ConferenceType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:conference) }

      include_examples "attachable interface"
      include_examples "categories container interface"

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

      describe "slug" do
        let(:query) { "{ slug }" }

        it "returns the conference' slug" do
          expect(response["slug"]).to eq(model.slug)
        end
      end

      describe "shortDescription" do
        let(:query) { '{ shortDescription { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["shortDescription"]["translation"]).to eq(model.short_description["en"])
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "hashtag" do
        let(:query) { "{ hashtag }" }

        it "returns the conference' hashtag" do
          expect(response["hashtag"]).to eq(model.hashtag)
        end
      end

      describe "slogan" do
        let(:query) { '{ slogan { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["slogan"]["translation"]).to eq(model.slogan["en"])
        end
      end

      describe "location" do
        let(:query) { "{ location }" }

        it "returns the conference' location" do
          expect(response["location"]).to eq(model.location)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the conference was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the conference was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the conference was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns the conference' reference" do
          expect(response["reference"]).to eq(model.reference)
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image field" do
          expect(response["heroImage"]).to eq(model.attached_uploader(:hero_image).path)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to eq(model.attached_uploader(:banner_image).path)
        end
      end

      describe "promoted" do
        let(:query) { "{ promoted }" }

        it "returns the promoted field" do
          expect(response["promoted"]).to eq(model.promoted)
        end
      end

      describe "objectives" do
        let(:query) { '{ objectives { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["objectives"]["translation"]).to eq(model.objectives["en"])
        end
      end

      describe "showStatistics" do
        let(:query) { " { showStatistics } " }

        it "returns the showStatistics field" do
          expect(response["showStatistics"]).to eq(model.show_statistics)
        end
      end

      describe "startDate" do
        let(:query) { "{ startDate }" }

        it "returns the start date of the conference" do
          expect(response["startDate"]).to eq(model.start_date.to_date.iso8601)
        end
      end

      describe "endDate" do
        let(:query) { "{ endDate }" }

        it "returns the date the conference ends" do
          expect(response["endDate"]).to eq(model.end_date.to_date.iso8601)
        end
      end

      describe "registrationsEnabled" do
        let(:query) { " { registrationsEnabled } " }

        it "returns the registrationsEnabled field" do
          expect(response["registrationsEnabled"]).to eq(model.registrations_enabled)
        end
      end

      describe "availableSlots" do
        let(:query) { " { availableSlots } " }

        it "returns the availableSlots field" do
          expect(response["availableSlots"]).to eq(model.available_slots)
        end
      end

      describe "registrationTerms" do
        let(:query) { '{ registrationTerms { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["registrationTerms"]["translation"]).to eq(model.registration_terms["en"])
        end
      end
    end
  end
end
