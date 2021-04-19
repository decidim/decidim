# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AreaTypeType do
      include_context "with a graphql class type"

      let(:model) { create(:area_type) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the area type's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the area type's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      describe "plural" do
        let(:query) { '{ plural { translation(locale: "en") } }' }

        it "returns the area type's plural" do
          expect(response["plural"]["translation"]).to eq(model.plural["en"])
        end
      end
    end
  end
end
