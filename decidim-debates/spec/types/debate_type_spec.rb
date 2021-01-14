# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/comments_examples"
require "decidim/core/test/shared_examples/authorable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"

module Decidim
  module Debates
    describe DebateType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:debate, :open_ama) }

      include_examples "categorizable interface"
      include_examples "authorable interface"
      include_examples "scopable interface"

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

      describe "instructions" do
        let(:query) { '{ instructions { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["instructions"]["translation"]).to eq(model.instructions["en"])
        end
      end

      describe "informationUpdates" do
        let(:query) { '{ informationUpdates { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["informationUpdates"]["translation"]).to eq(model.information_updates["en"])
        end
      end

      describe "startTime" do
        let(:query) { "{ startTime }" }

        it "returns the date when the debate starts" do
          expect(response["startTime"]).to eq(model.start_time.to_time.iso8601)
        end
      end

      describe "endTime" do
        let(:query) { "{ endTime }" }

        it "returns the date when the debate ends" do
          expect(response["endTime"]).to eq(model.end_time.to_time.iso8601)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the debate was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the debate was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "reference" do
        let(:query) { "{ reference }" }

        it "returns all the required fields" do
          expect(response).to include("reference" => model.reference.to_s)
        end
      end
    end
  end
end
