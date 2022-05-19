# frozen_string_literal: true

require "decidim/github_manager/poster"
require "webmock/rspec"

describe Decidim::GithubManager::Poster do
  let(:poster) { described_class.new(token: "abc", params: { title: "Hello world", body: "This is a test" }) }

  before do
    stub_request(:post, "https://api.github.com/repos/decidim/decidim/pulls")
      .to_return(status: 200)
  end

  describe ".create_pull_request!" do
    it "returns the respose from the server" do
      expect(poster.send(:create_pull_request!)).to be_a Faraday::Response
    end
  end
end
