# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe ScopeApiType do
      include_context "with a graphql class type"

      let!(:subscope) { create(:subscope) }
      let!(:parent) { subscope.parent }

      let(:model) { subscope }

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the scope's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      context "when it's a subscope" do
        let(:model) { subscope }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns its parent" do
            expect(response["parent"]).to eq("id" => parent.id.to_s)
          end
        end

        describe "children" do
          let(:query) { "{ children { id } }" }

          it "returns an empty array" do
            expect(response["children"]).to eq([])
          end
        end
      end

      context "when it's a parent scope" do
        let(:model) { parent }

        describe "parent" do
          let(:query) { "{ parent { id } }" }

          it "returns nil" do
            expect(response["parent"]).to be_nil
          end
        end

        describe "children" do
          let(:query) { "{ children { id } }" }

          it "returns its children" do
            expect(response["children"]).to eq([{ "id" => subscope.id.to_s }])
          end
        end
      end
    end
  end
end
