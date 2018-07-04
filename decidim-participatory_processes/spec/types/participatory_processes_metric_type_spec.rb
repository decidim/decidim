# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module ParticipatoryProcesses
    describe ParticipatoryProcessesMetricType, type: :graphql do
      before do
        Rails.cache.clear
      end

      include_context "with a graphql type"

      let(:created_at_date) { Time.zone.now }
      let!(:models) { create_list(:participatory_process, 4, created_at: created_at_date) }

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the ParticipatoryProcess' count" do
          expect(response).to include("count" => models.size)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the ParticipatoryProcess' metric data" do
          data = response.with_indifferent_access
          expect(data[:metric]).to include("key" => created_at_date.strftime("%Y-%m-%d"), "value" => models.size)
        end
      end

      describe "data" do
        let(:query) { "{ data { created_at } }" }

        it "returns the ParticipatoryProcess' data" do
          data = response.with_indifferent_access
          expect(data[:data].size).to eq(models.size)
          expect(data[:data]).to include("created_at" => created_at_date.strftime("%Y-%m-%d"))
        end
      end
    end
  end
end
