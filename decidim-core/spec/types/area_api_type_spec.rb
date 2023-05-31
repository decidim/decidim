# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe AreaApiType do
      include_context "with a graphql class type"

      let(:model) { create(:area, area_type:, organization: area_type.organization) }
      let(:area_type) { create(:area_type) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the area's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "name" do
        let(:query) { '{ name { translation(locale: "en") } }' }

        it "returns the area's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end

      describe "areaType" do
        let(:query) { "{ areaType { id } }" }

        it "returns the area's areaType" do
          expect(response["areaType"]["id"]).to eq(model.area_type.id.to_s)
        end
      end
    end
  end
end
