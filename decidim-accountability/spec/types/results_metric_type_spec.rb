# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Assemblies
    describe AssembliesMetricType, type: :graphql do
      before do
        Rails.cache.clear
      end

      include_context "with a graphql type"

      let(:published_at_date) { Time.zone.now }
      let!(:models) { create_list(:assembly, 4, published_at: published_at_date) }

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the Assembly's count" do
          expect(response).to include("count" => models.size)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the Assembly's metric data" do
          data = response.with_indifferent_access
          expect(data[:metric]).to include("key" => published_at_date.strftime("%Y-%m-%d"), "value" => models.size)
        end
      end

      describe "data" do
        let(:query) { "{ data { published_at } }" }

        it "returns the Assembly's data" do
          data = response.with_indifferent_access
          expect(data[:data].size).to eq(models.size)
          expect(data[:data]).to include("published_at" => published_at_date.strftime("%Y-%m-%d"))
        end
      end
    end
  end
end
