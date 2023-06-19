# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::ByLabel do
  let(:querier) { described_class.new(token: "abc") }
  let(:date) { Date.new(2020, 1, 1) }
  let(:stubbed_url) { "https://api.github.com/repos/decidim/decidim/issues?labels=type:%20fix&per_page=100&since=2019-10-03&state=closed" }

  before do
    allow(Date).to receive(:today).and_return(date)
    stub_request(:get, stubbed_url)
      .to_return(status: 200, body: stubbed_response, headers: {})
  end

  describe ".call" do
    let(:stubbed_response) do
      <<~RESPONSE
        [
          {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]},
          {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "module: core"}]}
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

    context "with excluded labels on the response" do
      let(:stubbed_response) do
        <<~RESPONSE
          [
            {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]},
            {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "backport"}]}
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
  end
end
