# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Pages
    describe PageType, type: :graphql do
      include_context "with a graphql class type"

      let(:model) { create(:page) }

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

      describe "body" do
        let(:query) { '{ body { translation(locale: "en")}}' }

        it "returns all the required fields" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when the page was created" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "updatedAt" do
        let(:query) { "{ updatedAt }" }

        it "returns when the page was updated" do
          expect(response["updatedAt"]).to eq(model.updated_at.to_time.iso8601)
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns all the required fields" do
          expect(response["url"]).to eq(Decidim::ResourceLocatorPresenter.new(model).url)
        end
      end
    end
  end
end
