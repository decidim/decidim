# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe CategoryType do
      include_context "with a graphql class type"

      let!(:subcategory) { create(:subcategory) }
      let!(:parent) { subcategory.parent }

      let(:model) { subcategory }

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the category's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      context "when it's a subcategory" do
        let(:model) { subcategory }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns its parent" do
            expect(response["parent"]).to eq("id" => parent.id.to_s)
          end
        end

        describe "subcategories" do
          let(:query) { "{ subcategories { id } }" }

          it "returns an empty array" do
            expect(response["subcategories"]).to eq([])
          end
        end
      end

      context "when it's a parent category" do
        let(:model) { parent }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns nil" do
            expect(response["parent"]).to be_nil
          end
        end

        describe "subcategories" do
          let(:query) { "{ subcategories { id } }" }

          it "returns its subcategories" do
            expect(response["subcategories"]).to eq([{ "id" => subcategory.id.to_s }])
          end
        end
      end
    end
  end
end
