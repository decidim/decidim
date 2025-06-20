# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Conferences
    describe ConferenceType, type: :graphql do
      include_context "with a graphql class type"

      let(:registrations_enabled) { true }
      let(:model) { create(:conference, registrations_enabled:) }
      let!(:published_speaker) { create(:conference_speaker, :published, conference: model) }
      let!(:unpublished_speaker) { create(:conference_speaker, conference: model) }
      let(:organization) { model.organization }

      include_examples "attachable interface"
      include_examples "categories container interface"
      include_examples "taxonomizable interface"
      include_examples "referable interface"
      include_examples "attachable collection interface with attachment"
      include_examples "followable interface"
      include_examples "traceable interface"
      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to include("id" => model.id.to_s)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(EngineRouter.main_proxy(model).conference_url(model))
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

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when the conference was published" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "heroImage" do
        let(:query) { "{ heroImage }" }

        it "returns the hero image field" do
          expect(response["heroImage"]).to be_blob_url(model.hero_image.blob)
        end
      end

      describe "bannerImage" do
        let(:query) { "{ bannerImage }" }

        it "returns the banner image field" do
          expect(response["bannerImage"]).to be_blob_url(model.banner_image.blob)
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

      describe "speakers" do
        let(:query) { " { speakers { fullName } } " }

        it "returns the list of published speakers" do
          expect(response["speakers"].count).to eq(1)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the Conference's weight" do
          expect(response["weight"]).to eq(model.weight)
        end
      end

      describe "registration_types" do
        let(:query) { " { registrationTypes { id } } " }
        let!(:registration_type) { create(:registration_type, conference: model) }

        context "when registrations are enabled" do
          it "does not return any registration type" do
            expect(response["registrationTypes"]).to eq([{ "id" => registration_type.id.to_s }])
          end
        end

        context "when registrations are disabled" do
          let(:registrations_enabled) { false }

          it "does not return any registration type" do
            expect(response["registrationTypes"]).to eq([nil])
          end
        end

        context "when registrations are not published" do
          let!(:registration_type) { create(:registration_type, conference: model, published_at: nil) }

          it "does not return any registration type" do
            expect(response["registrationTypes"]).to eq([])
          end
        end
      end
    end
  end
end
