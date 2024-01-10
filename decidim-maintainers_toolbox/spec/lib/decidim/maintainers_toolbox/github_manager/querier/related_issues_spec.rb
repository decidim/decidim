# frozen_string_literal: true

require "decidim/github_manager/querier"
require "webmock/rspec"

describe Decidim::GithubManager::Querier::RelatedIssues do
  let(:querier) { described_class.new(token: "abc", issue_id: 12_345) }
  let(:response) do
    [
      { id: 456, title: "Backport 'Fix whatever' to v0.1", state: "merged" },
      { id: 457, title: "Backport 'Fix whatever' to v0.2", state: "merged" }
    ]
  end
  let(:stubbed_body) do
    <<~RESPONSE
      [
        {
          "event": "cross-referenced",
          "source": {
            "issue": { "number": 456, "title": "Backport 'Fix whatever' to v0.1", "state": "merged", "repository": { "full_name": "decidim/decidim" } }
          }
        },
        {
          "event": "cross-referenced",
          "source": {
            "issue": { "number": 457, "title": "Backport 'Fix whatever' to v0.2", "state": "merged", "repository": { "full_name": "decidim/decidim" } }
          }
        }
      ]
    RESPONSE
  end

  before do
    stub_request(:get, "https://api.github.com/repos/decidim/decidim/issues/12345/timeline?per_page=100")
      .to_return(status: 200, body: stubbed_body, headers: {})
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

  context "when the reference comes from a fork" do
    let(:stubbed_body) do
      <<~RESPONSE
        [
          {
            "event": "cross-referenced",
            "source": {
              "issue": { "number": 456, "title": "Backport 'Fix whatever' to v0.1", "state": "merged", "repository": { "full_name": "decidim/decidim" } }
            }
          },
          {
            "event": "cross-referenced",
            "source": {
              "issue": { "number": 457, "title": "Backport 'Fix whatever' to v0.1", "state": "merged", "repository": { "full_name": "a_decidim_fork/decidim" } }
            }
          }
        ]
      RESPONSE
    end
    let(:response) do
      [
        { id: 456, title: "Backport 'Fix whatever' to v0.1", state: "merged" }
      ]
    end

    it "gets ignored" do
      expect(querier.call).to eq response
    end
  end

  context "when a related issue title has leading or trailing spaces" do
    let(:stubbed_body) do
      <<~RESPONSE
        [
          {
            "event": "cross-referenced",
            "source": {
              "issue": { "number": 456, "title": "  Backport 'Fix title with leading spaces' to v0.1", "state": "merged", "repository": { "full_name": "decidim/decidim" } }
            }
          },
          {
            "event": "cross-referenced",
            "source": {
              "issue": { "number": 457, "title": "Backport 'Fix title with trailing spaces' to v0.2   ", "state": "merged", "repository": { "full_name": "decidim/decidim" } }
            }
          }
        ]
      RESPONSE
    end
    let(:response) do
      [
        { id: 456, title: "Backport 'Fix title with leading spaces' to v0.1", state: "merged" },
        { id: 457, title: "Backport 'Fix title with trailing spaces' to v0.2", state: "merged" }
      ]
    end

    it "gets the titles striped" do
      expect(querier.call).to eq response
    end
  end
end
