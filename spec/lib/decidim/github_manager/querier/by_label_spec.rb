# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"
require "active_support/testing/time_helpers"

describe Decidim::GithubManager::Querier::ByLabel do
  include ActiveSupport::Testing::TimeHelpers

  let(:querier) { described_class.new(token: "abc", days_to_check_from:) }
  let(:days_to_check_from) { 90 }
  let(:date) { Date.new(2020, 1, 1) }
  let(:stubbed_url) { "https://api.github.com/repos/decidim/decidim/issues?labels=type:%20fix&per_page=100&since=2019-10-03&state=closed" }
  let(:stubbed_headers) { {} }

  before do
    Time.use_zone("UTC") do
      travel_to Time.zone.parse("2020-1-1")
      stub_request(:get, stubbed_url).to_return(status: 200, body: stubbed_body, headers: stubbed_headers)
    end
  end

  describe ".call" do
    let(:stubbed_body) do
      <<~RESPONSE
        [
          {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }},
          {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "module: core"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }}
        ]
      RESPONSE
    end
    let(:result) do
      [
        { id: 12_345, title: "Fix whatever" },
        { id: 98_765, title: "Fix another thing" }
      ]
    end

    it "returns a valid result" do
      expect(querier.call).to eq result
    end

    context "when there is pagination" do
      let(:next_stubbed_url) { "https://api.github.com/repositories/65914086/issues?labels=type%3A+fix&per_page=100&since=2019-10-03&state=closed&page=2" }
      let(:next_stubbed_body) do
        <<~RESPONSE
          [
            {"number": 56789, "title": "Fix one last thing", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }}
          ]
        RESPONSE
      end
      let(:stubbed_headers) do
        {
          "link" => "<#{next_stubbed_url}>; rel=\"next\", <https://api.github.com/repositories/65914086/issues?labels=type%3A+fix&per_page=100&since=219-10-03&state=closed&page=8>; rel=\"last\""
        }
      end
      let(:result) do
        [
          { id: 12_345, title: "Fix whatever" },
          { id: 98_765, title: "Fix another thing" },
          { id: 56_789, title: "Fix one last thing" }
        ]
      end

      before do
        stub_request(:get, next_stubbed_url).to_return(status: 200, body: next_stubbed_body, headers: {})
      end

      it "returns a valid result" do
        expect(querier.call).to eq result
      end
    end

    context "with excluded labels on the response" do
      let(:stubbed_body) do
        <<~RESPONSE
          [
            {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }},
            {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "backport"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }}
          ]
        RESPONSE
      end
      let(:result) do
        [
          { id: 12_345, title: "Fix whatever" }
        ]
      end

      it "returns a valid result" do
        expect(querier.call).to eq result
      end
    end

    context "when there are issues labeled with `type: fix`" do
      let(:stubbed_body) do
        <<~RESPONSE
          [
            {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }},
            {"number": 98765, "title": "An issue labeled incorrectly with type: fix", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]}
          ]
        RESPONSE
      end
      let(:result) do
        [
          { id: 12_345, title: "Fix whatever" }
        ]
      end

      it "returns a valid result" do
        expect(querier.call).to eq result
      end
    end

    context "when there are pull requests that were not merged" do
      let(:stubbed_body) do
        <<~RESPONSE
          [
            {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }},
            {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "nil" }}
          ]
        RESPONSE
      end
      let(:result) do
        [
          { id: 12_345, title: "Fix whatever" }
        ]
      end

      it "returns a valid result" do
        expect(querier.call).to eq result
      end
    end

    context "when it was merged before the days_to_check_from" do
      let(:stubbed_body) do
        <<~RESPONSE
          [
            {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}], "pull_request": { "merged_at": "2017-04-23T01:01:01Z" }},
            {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "module: core"}], "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }}
          ]
        RESPONSE
      end
      let(:result) do
        [
          { id: 98_765, title: "Fix another thing" }
        ]
      end

      it "returns a valid result" do
        expect(querier.call).to eq result
      end
    end
  end
end
