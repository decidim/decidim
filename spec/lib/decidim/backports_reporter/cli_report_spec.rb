# frozen_string_literal: true

require "decidim/backports_reporter/cli_report"

describe Decidim::BackportsReporter::CLIReport do
  subject { described_class.new(report:, last_version_number:).call }

  let(:report) do
    [{ id:, title:, related_issues: }]
  end
  let(:id) { 10_234 }
  let(:title) { "Fix the world" }
  let(:related_issues) { [] }
  let(:last_version_number) { "0.27" }

  describe ".call" do
    context "when the id is shorter" do
      let(:id) { 1_234 }

      it "returns a valid response" do
        response = <<~RESPONSE
          |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #1234  | Fix the world                                                                       |      None      |      None      |
        RESPONSE
        expect(subject).to eq response
      end
    end

    context "when the title is really long" do
      let(:last_version_number) { "0.31" }
      let(:title) { "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog" }

      it "returns a valid response" do
        response = <<~RESPONSE
          |   ID   |                                        Title                                        | Backport v0.31 | Backport v0.30 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #10234 | The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the ... |      None      |      None      |
        RESPONSE
        expect(subject).to eq response
      end
    end

    context "without related_issues" do
      it "returns a valid response" do
        response = <<~RESPONSE
          |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
          |--------|-------------------------------------------------------------------------------------|----------------|----------------|
          | #10234 | Fix the world                                                                       |      None      |      None      |
        RESPONSE
        expect(subject).to eq response
      end

      context "with another version number" do
        let(:last_version_number) { "0.31" }

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.31 | Backport v0.30 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #10234 | Fix the world                                                                       |      None      |      None      |
          RESPONSE
          expect(subject).to eq response
        end
      end
    end

    context "with related_issues" do
      context "when there is not a backport" do
        let(:related_issues) { [{ id: 9876, title: "Whatever", state: "closed" }] }

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #10234 | Fix the world                                                                       |      None      |      None      |
          RESPONSE
          expect(subject).to eq response
        end
      end

      context "when there is a backport" do
        let(:related_issues) { [{ id: 9876, title: 'Backport "Fix the world" to v0.26', state: "merged" }] }

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #10234 | Fix the world                                                                       |      None      |      \e[34m#9876\e[0m     |
          RESPONSE
          expect(subject).to eq response
        end
      end

      context "when there are two backports" do
        let(:related_issues) do
          [
            { id: 9876, title: 'Backport "Fix the world" to v0.26', state: "merged" },
            { id: 9875, title: 'Backport "Fix the world" to v0.27', state: "merged" }
          ]
        end

        it "returns a valid response" do
          response = <<~RESPONSE
            |   ID   |                                        Title                                        | Backport v0.27 | Backport v0.26 |
            |--------|-------------------------------------------------------------------------------------|----------------|----------------|
            | #10234 | Fix the world                                                                       |      \e[34m#9875\e[0m     |      \e[34m#9876\e[0m     |
          RESPONSE
          expect(subject).to eq response
        end
      end
    end
  end
end
