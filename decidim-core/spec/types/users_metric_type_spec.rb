# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe UsersMetricType, type: :graphql do

      before(:each) do
        Rails.cache.clear
      end

      include_context "with a graphql type"

      let(:confirmed_at_date) { Time.zone.now }
      let!(:current_user) { } # :current_user overwritten to evade creation
      let!(:models) { create_list(:user, 4, confirmed_at: confirmed_at_date, organization: current_organization) }

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the User's count" do
          expect(response).to include("count" => models.size)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the User's metric data" do
          data = response.with_indifferent_access
          expect(data[:metric]).to include({"key" => confirmed_at_date.strftime("%Y-%m-%d"), "value" => models.size})
        end
      end

      describe "data" do
        let(:query) { "{ data { confirmed_at } }" }

        it "returns the User's data" do
          data = response.with_indifferent_access
          expect(data[:data].size).to eq(models.size)
          expect(data[:data]).to include("confirmed_at" => confirmed_at_date.strftime("%Y-%m-%d"))
        end
      end
    end
  end
end
