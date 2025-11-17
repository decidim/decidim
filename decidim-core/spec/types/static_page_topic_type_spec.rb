# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe StaticPageTopicType do
      include_context "with a graphql class type"

      let!(:model) { create(:static_page_topic, show_in_footer: true) }

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

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the description field" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "showInFooter" do
        let(:query) { "{ showInFooter }" }

        it "returns the showInFooter field" do
          expect(response["showInFooter"]).to be_truthy
        end
      end

      describe "static_pages" do
        let(:query) { "{ staticPages { id } }" }

        context "when the topic has no static pages" do
          it "returns the static pages object" do
            expect(response["staticPages"]).to eq([])
          end
        end

        context "when the topic has static pages" do
          let!(:static_page) { create(:static_page, topic: model) }

          it "returns the pages object" do
            expect(response["staticPages"]).to eq([{ "id" => static_page.id.to_s }])
          end
        end
      end
    end
  end
end
