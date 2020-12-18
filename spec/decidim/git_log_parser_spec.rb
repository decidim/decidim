# frozen_string_literal: true

require "decidim/git_log_parser"

describe Decidim::GitLogParser do
  let(:full_log) {}
  let(:parser) { Decidim::GitLogParser.new(full_log) }

  before do
    parser.parse
  end

  context "with an empty log" do
    it "parses nothing" do
      parser.parse
      expect(parser.categorized).to be_nil
      expect(parser.uncategorized).to be_nil
    end
  end

  context "with all type of log with entries" do
    let(:full_log) { <<~EOLOG }
      commit ee8242536

      Backport "Do not html_escape twice meetings title in cells" to v0.23 (#6780)

      Notes:


      commit f99ef0f15

      Add more than one attachment to proposals (#6532)

      Notes:

      Changed: **decidim-core**, **decidim-proposals**

      commit 85e981233

      Refactor meetings test to be resilient to flakys (#6694) (#6706)

      Notes:

      Fixed: **decidim-budgets**, **decidim-core**, **decidim-meetings*

    EOLOG

    it "correctly parses the entries" do
      expected_categorized = {
        "Changed" => ["- **decidim-core**, **decidim-proposals**: Add more than one attachment to proposals [\\#6532](https://github.com/decidim/decidim/pull/6532)"],
        "Fixed" => ["- **decidim-budgets**, **decidim-core**, **decidim-meetings*: Refactor meetings test to be resilient to flakys (#6694) [\\#6706](https://github.com/decidim/decidim/pull/6706)"]
      }
      expected_uncategorized = [%(Backport "Do not html_escape twice meetings title in cells" to v0.23 [\\#6780](https://github.com/decidim/decidim/pull/6780))]
      expect(parser.categorized).to eq(expected_categorized)
      expect(parser.uncategorized).to eq(expected_uncategorized)
    end
  end
end
