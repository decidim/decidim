# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Proposals
    describe VotesMetricType, type: :graphql do
      before do
        Rails.cache.clear
      end

      include_context "with a graphql type"

      let(:created_at_date) { Time.zone.now }
      let(:component) { create(:proposal_component, :published) }
      let(:proposal) { create(:proposal, :published, component: component) }
      let!(:models) { create_list(:proposal_vote, 4, created_at: created_at_date, proposal: proposal) }

      let(:today) { Time.zone.today }
      let!(:models) do
        (0..4).each do |count|
          create(:metric, day: (today - count.days), cumulative: (4 - count), quantity: 1, metric_type: "votes", organization: current_organization)
        end
      end

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the Vote's last day cumulative count" do
          expect(response).to include("count" => 4)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the Vote's metric data" do
          data = response.with_indifferent_access
          expect(data[:metric].size).to eq(5)
          expect(data[:metric]).to include("key" => today.strftime("%Y-%m-%d"), "value" => 4)
          expect(data[:metric]).to include("key" => (today - 4.days).strftime("%Y-%m-%d"), "value" => 0)
        end
      end
    end
  end
end
