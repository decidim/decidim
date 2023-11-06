# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::ByIssueId do
  let(:querier) { described_class.new(token: "abc", issue_id: 12_345) }

  before do
    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues/12345")
      .to_return(status: 200, body: '{"number": 12345, "title": "Fix whatever", "labels": [{"name": "type: fix"}, {"name": "module: admin"}]}', headers: {})
  end

  describe ".call" do
    let(:response) do
      {
        labels: ["module: admin", "type: fix"],
        modules: ["module: admin"],
        type: ["type: fix"],
        id: 12_345,
        title: "Fix whatever"
      }
    end

    it "returns a valid response" do
      expect(querier.call).to eq response
    end
  end
end
