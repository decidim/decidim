# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier do
  let(:querier) { described_class.new(token: "abc", issue_id: 12_345) }

  before do
    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues/12345")
      .to_return(status: 200, body: '{"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]}', headers: {})
  end

  describe ".issue_metadata" do
    it "returns a valid response" do
      expected_response = { "labels" => [{ "name" => "type: fix" }, { "name" => "module: admin" }], "number" => 12_345, "title" => "Fix whatever" }
      expect(querier.send(:issue_metadata)).to eq expected_response
    end
  end

  describe ".parse" do
    it "returns a valid response" do
      metadata = { "number" => 98_765, "title" => "Fix something", "labels" => [{ "name" => "type: fix" }, { "name" => "module: core" }] }
      expected_response = { id: 98_765, labels: ["module: core", "type: fix"], modules: ["module: core"], title: "Fix something", type: ["type: fix"] }

      expect(querier.send(:parse, metadata)).to eq expected_response
    end
  end
end
