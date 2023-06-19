# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::ByLabel do
  let(:querier) { described_class.new(token: "abc", label: "type: fix") }

  before do
    stubbed_response = <<~RESPONSE
    [
      {"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]},
      {"number": 98765, "title": "Fix another thing", "labels": [{"name": "type: fix"}, {"name": "module: core"}]}
    ]
    RESPONSE

    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues?labels=type:%20fix&since=2023-06-09&state=closed")
      .to_return(status: 200, body: stubbed_response, headers: {})
  end

  describe ".call" do
    let(:response) do
      [
        { id: 12_345, title: "Fix whatever" },
        { id: 98_765, title: "Fix another thing" }
      ]
    end

    it "returns a valid response" do
      expect(querier.call).to eq response
    end
  end
end
