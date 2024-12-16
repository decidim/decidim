# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe TaxonomyType do
      include_context "with a graphql class type"

      let!(:root_taxonomy) { create(:taxonomy) }
      let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: root_taxonomy.organization) }

      let(:model) { root_taxonomy }

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the taxonomy's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      context "when it is a child taxonomy" do
        let(:model) { taxonomy }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns its parent" do
            expect(response["parent"]).to eq("id" => root_taxonomy.id.to_s)
          end
        end

        describe "children" do
          let(:query) { "{ children { id } }" }

          it "returns an empty array" do
            expect(response["children"]).to eq([])
          end
        end

        describe "isRoot" do
          let(:query) { "{ isRoot }" }

          it "returns false" do
            expect(response["isRoot"]).to be_falsey
          end
        end
      end

      context "when it is a root taxonomy" do
        let(:model) { root_taxonomy }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns nil" do
            expect(response["parent"]).to be_nil
          end
        end

        describe "children" do
          let(:query) { "{ children { id } }" }

          it "returns its children" do
            expect(response["children"]).to eq([{ "id" => taxonomy.id.to_s }])
          end
        end

        describe "isRoot" do
          let(:query) { "{ isRoot }" }

          it "returns true" do
            expect(response["isRoot"]).to be_truthy
          end
        end
      end
    end
  end
end
