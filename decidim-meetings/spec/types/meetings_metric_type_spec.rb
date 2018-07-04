# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Meetings
    describe MeetingsMetricType, type: :graphql do
      before do
        Rails.cache.clear
      end

      include_context "with a graphql type"

      let(:start_time_date) { Time.zone.now }
      let!(:models) { create_list(:meeting, 4, start_time: start_time_date) }

      describe "count" do
        let(:query) { "{ count }" }

        it "returns the Meeting's count" do
          expect(response).to include("count" => models.size)
        end
      end

      describe "metric" do
        let(:query) { "{ metric { key value } }" }

        it "returns the Meeting's metric data" do
          data = response.with_indifferent_access
          expect(data[:metric]).to include("key" => start_time_date.strftime("%Y-%m-%d"), "value" => models.size)
        end
      end

      describe "data" do
        let(:query) { "{ data { start_time } }" }

        it "returns the Meeting's data" do
          data = response.with_indifferent_access
          expect(data[:data].size).to eq(models.size)
          expect(data[:data]).to include("start_time" => start_time_date.strftime("%Y-%m-%d"))
        end
      end
    end
  end
end
