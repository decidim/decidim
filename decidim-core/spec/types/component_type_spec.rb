# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe ComponentType do
      include_context "with a graphql class type"

      let(:model) { create(:dummy_component) }

      include_examples "timestamps interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the id field" do
          expect(response).to eq("id" => model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { %[{ name { translation(locale: "en") } }] }

        it "returns the component's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      describe "participatorySpace" do
        let(:query) { "{ participatorySpace { id } }" }

        it "returns the participatorySpace field" do
          expect(response["participatorySpace"]["id"]).to eq(model.participatory_space.id.to_s)
        end
      end

      describe "visible" do
        let(:query) { "{ visible }" }

        it "returns the visible field" do
          expect(response["visible"]).to be_truthy
        end
      end

      describe "published_at" do
        let(:query) { "{ publishedAt }" }

        context "when is set" do
          it "returns the publishedAt field" do
            expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
          end
        end
      end

      describe "url" do
        let(:query) { "{ url }" }

        it "returns the url field" do
          expect(response["url"]).to eq(Decidim::EngineRouter.main_proxy(model).root_url)
        end
      end

      describe "weight" do
        let(:query) { "{ weight }" }

        it "returns the weight field" do
          expect(response).to eq("weight" => model.weight)
        end
      end
    end
  end
end
