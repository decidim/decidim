# frozen_string_literal: true

require "decidim/backports_reporter/cli_report"

describe Decidim::BackportsReporter::CLIReport do
  subject { described_class.new(report:, last_version_number:).call }

  let(:report) do
    [{ id: 1234, title:, related_issues: [] }]
  end
  let(:title) { "Fix the world" }
  let(:last_version_number) { "0.27" }

  describe ".call" do
    context "when the title is really long" do
      let(:last_version_number) { "0.31" }
      let(:title) { "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog" }

      it "returns a valid response" do
        response = <<~RESPONSE
          |   ID   |                                        Title                                        | Backport v0.31 | Backport v0.30 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #1234 | The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the ... |      None      |      None      |
        RESPONSE
        expect(subject).to eq response
      end
    end

    context "without related_issues" do
      it "returns a valid response" do
        response = <<~RESPONSE
          |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #1234 | Fix the world                                                                       |      None      |      None      |
        RESPONSE
        expect(subject).to eq response
      end

      context "with another version number" do
        let(:last_version_number) { "0.31" }

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.31 | Backport v0.30 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #1234 | Fix the world                                                                       |      None      |      None      |
          RESPONSE
          expect(subject).to eq response
        end
      end
    end

    context "with related_issues" do
      context "when it is not a backport" do
        let(:report) do
          [{ id: 1234, title: "Fix the world", related_issues: [id: 9876, title: "Whatever", state: "closed"] }]
        end

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #1234 | Fix the world                                                                       |      None      |      None      |
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
            |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #1234 | Fix the world                                                                       |      None      |      \e[34m#9876\e[0m     |
          RESPONSE
          expect(subject).to eq response
        end
      end
    end
  end
end
