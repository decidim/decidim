# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe ComponentType do
      include_context "with a graphql class type"

      let(:model) { create(:dummy_component) }

      describe "name" do
        let(:query) { %[{ name { translation(locale: "en") } }] }

        it "returns the component's name" do
          expect(response["name"]["translation"]).to eq(model.name["en"])
        end
      end
    end
  end
end
