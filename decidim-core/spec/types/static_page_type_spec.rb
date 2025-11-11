# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe StaticPageType do
      include_context "with a graphql class type"

      let!(:model) { create(:static_page, :with_topic) }
      let!(:organization) { model.organization }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the title field" do
          expect(response["title"]["translation"]).to eq(translated(model.title))
        end
      end

      describe "content" do
        let(:query) { '{ content { translation(locale: "en")}}' }

        it "returns the content field" do
          expect(response["content"]["translation"]).to eq(translated(model.content))
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the url field" do
          expect(response["url"]).to eq(Decidim::EngineRouter.new("decidim", { host: organization.host }).page_url(model.reload))
        end
      end

      describe "topic" do
        let(:query) { "{ topic { id } }" }

        it "returns the topic field" do
          expect(response["topic"]["id"]).to eq(model.topic.id.to_s)
        end
      end
    end
  end
end
