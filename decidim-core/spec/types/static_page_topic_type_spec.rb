# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe StaticPageTopicType do
      include_context "with a graphql class type"
      include_examples "timestamps interface"

      let!(:model) { create(:static_page_topic, show_in_footer: true) }

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

      describe "description" do
        let(:query) { '{ description { translation(locale: "en")}}' }

        it "returns the static page's description" do
          expect(response["description"]["translation"]).to eq(translated(model.description))
        end
      end

      describe "showInFooter" do
        let(:query) { "{ showInFooter }" }

        it "returns the showInFooter" do
          expect(response["showInFooter"]).to be_truthy
        end
      end
    end
  end
end
