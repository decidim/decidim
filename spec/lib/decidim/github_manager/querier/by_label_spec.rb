# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::ByLabel do
  let(:querier) { described_class.new(token: "abc", label: "type: fix", exclude_label: "backport") }

  before do
    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues?labels=type:%20fix&since=2023-06-09&state=closed")
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
