# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe UsersMetricType, type: :graphql do
      include_context "with a graphql type"

      let(:today) { Time.zone.today }
      let!(:models) do
        (0..4).each do |count|
          create(:metric, day: (today - count.days), cumulative: (4 - count), quantity: 1, metric_type: "users", organization: current_organization)
        end
      end

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the User's last day cumulative count" do
          puts ">>>>> #{Decidim::Metric.all.as_json}"
          puts ">>>>> #{response}"
          expect(response).to include("count" => 4)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the User's metric data" do
          data = response.with_indifferent_access
          expect(data[:metric].size).to eq(5)
          expect(data[:metric]).to include("key" => today.strftime("%Y-%m-%d"), "value" => 4)
          expect(data[:metric]).to include("key" => (today - 4.days).strftime("%Y-%m-%d"), "value" => 0)
        end
      end
    end
  end
end
