# frozen_string_literal: true

require "decidim/backports_reporter/cli_report"

describe Decidim::BackportsReporter::CLIReport do
  subject { described_class.new(report:).call }

  describe ".call" do
    context "without related_issues" do
      let(:report) do
        [{ id: 1234, title: "Fix the world", related_issues: [] }]
      end

      it "returns a valid response" do
        response = <<~RESPONSE
          | ID     | Title                                                                               | Backport v0.27 | Backport v0.26 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #1234 | Fix the world                                                                       | None           | None           |
        RESPONSE
        expect(subject).to eq response
      end
    end

    context "with related_issues" do
      context "when it is not a backport" do
        let(:report) do
          [{ id: 1234, title: "Fix the world", related_issues: [id: 9876, title: "Whatever", state: "closed"] }]
        end

        it "returns a valid response" do
          response = <<~RESPONSE
            | ID     | Title                                                                               | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #1234 | Fix the world                                                                       | None           | None           |
          RESPONSE
          expect(subject).to eq response
        end
      end

      context "when it is a backport" do
        let(:report) do
          [{ id: 1234, title: "Fix the world", related_issues: [id: 9876, title: 'Backport "Fix the world" to v0.26', state: "merged"] }]
        end

        it "returns a valid response" do
          response = <<~RESPONSE
            | ID     | Title                                                                               | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #1234 | Fix the world                                                                       | None           | \e[31m#9876\e[0m          |
          RESPONSE
          expect(subject).to eq response
        end
      end
    end
  end
end
