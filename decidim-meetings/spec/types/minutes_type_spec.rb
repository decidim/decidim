# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Meetings
    describe MinutesType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:minutes) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the minutes's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "description" do
        let(:query) { '{ description { translation(locale: "en") } }' }

        it "returns the service's description" do
          expect(response["description"]["translation"]).to eq(model.description["en"])
        end
      end

      describe "videoUrl" do
        let(:query) { "{ videoUrl }" }

        it "returns the minutes's video_url" do
          expect(response["videoUrl"]).to eq(model.video_url)
        end
      end

      describe "audioUrl" do
        let(:query) { "{ audioUrl }" }

        it "returns the minutes's audio_url" do
          expect(response["audioUrl"]).to eq(model.audio_url)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when was this query created at" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when was this query updated at" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end
    end
  end
end
