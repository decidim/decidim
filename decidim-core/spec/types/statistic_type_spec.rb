# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe StatisticType do
      subject { described_class }

      include_context "with a graphql class type"
      let(:model) { [:foo, 123] }

      describe "name" do
        let(:query) { "{ name }" }

        it "returns the statistic's name" do
          expect(response["name"]).to eq("foo")
        end
      end

      describe "value" do
        let(:query) { "{ value }" }

        it "returns the statistic's name" do
          expect(response["value"]).to eq(123)
        end
      end
    end
  end
end
