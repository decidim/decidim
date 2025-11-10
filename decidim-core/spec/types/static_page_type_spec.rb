# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe StaticPageType do
      let!(:model) { create(:static_page, :with_topic) }
      let!(:organization) { model.organization }

      include_context "with a graphql class type"
      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the static page's id" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale: "en")}}' }

        it "returns the static page's title" do
          expect(response["title"]["translation"]).to eq(translated(model.title))
        end
      end

      describe "content" do
        let(:query) { '{ content { translation(locale: "en")}}' }

        it "returns the static page's content" do
          expect(response["content"]["translation"]).to eq(translated(model.content))
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the static page's url" do
          expect(response["url"]).to eq(Decidim::EngineRouter.new("decidim", { host: organization.host }).page_url(model.reload))
        end
      end

      describe "topic" do
        let(:query) { "{ topic { id } }" }

        it "returns the static page's topic" do
          expect(response["topic"]["id"]).to eq(model.topic.id.to_s)
        end
      end
    end
  end
end
