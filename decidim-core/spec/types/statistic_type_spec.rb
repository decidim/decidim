# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test"

module Decidim
  module Core
    describe StatisticType do
      subject { described_class }

      include_context "with a graphql class type"

      let(:organization) do
        double("Organization", available_locales: [:en, :es, :ca])
      end
      let(:model) { [organization, { name: "foo", key: "foo", data: [123] }] }

      describe "key" do
        let(:query) { "{ key }" }

        it "returns the statistic's key name" do
          expect(response["key"]).to eq("foo")
        end
      end

      describe "name" do
        let(:query) { "{ name { translation(locale:  \"en\")} }" }

        it "returns the statistic's name" do
          expect(response["name"]["translation"]).to eq("Foo")
        end
      end

      describe "value" do
        let(:query) { "{ value }" }

        it "returns the statistic's value" do
          expect(response["value"]).to eq(123)
        end
      end
    end
  end
end
