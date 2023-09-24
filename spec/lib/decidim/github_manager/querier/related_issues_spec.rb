# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::RelatedIssues do
  let(:querier) { described_class.new(token: "abc", issue_id: 12_345) }

  before do
    stubbed_response = <<~RESPONSE
      [
        {
          "event": "cross-referenced",
          "source": {
            "issue": { "number": 456, "title": "Backport 'Fix whatever' to v0.1", "state": "merged" }
          }
        },
        {
          "event": "cross-referenced",
          "source": {
            "issue": { "number": 457, "title": "Backport 'Fix whatever' to v0.2", "state": "merged" }
          }
        }
      ]
    RESPONSE

    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues/12345/timeline?per_page=100")
      .to_return(status: 200, body: stubbed_response, headers: {})
  end

  describe ".call" do
    let(:response) do
      [
        { id: 456, title: "Backport 'Fix whatever' to v0.1", state: "merged" },
        { id: 457, title: "Backport 'Fix whatever' to v0.2", state: "merged" }
      ]
    end

    it "returns a valid response" do
      expect(querier.call).to eq response
    end
  end
end
