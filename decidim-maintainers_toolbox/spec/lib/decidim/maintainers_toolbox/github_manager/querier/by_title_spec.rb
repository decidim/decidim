# frozen_string_literal: true

require "decidim/maintainers_toolbox/github_manager/querier"
require "webmock/rspec"

describe Decidim::MaintainersToolbox::GithubManager::Querier::ByTitle do
  let(:querier) { described_class.new(token: "abc", title: title, state: state) }
  let(:title) { "Fix whatever" }
  let(:state) { "open" }

  let(:stubbed_url) { "https://api.github.com/repos/decidim/decidim/issues?per_page=100&state=open&title=Fix%20whatever" }
  let(:stubbed_headers) { {} }

  before do
    stub_request(:get, stubbed_url).to_return(status: 200, body: stubbed_body, headers: stubbed_headers)
  end

  describe ".call" do
    let(:stubbed_body) do
      <<~RESPONSE
        [
          {"number": 12345, "title": "Fix whatever", "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }},
          {"number": 98765, "title": "Fix whatever (part 2)", "pull_request": { "merged_at": "2020-01-01T01:01:01Z" }}
        ]
      RESPONSE
    end
    let(:result) do
      [
        { id: 12_345, title: "Fix whatever" },
        { id: 98_765, title: "Fix whatever (part 2)" }
      ]
    end

    it "returns a valid result" do
      expect(querier.call).to eq result
    end
  end
end
