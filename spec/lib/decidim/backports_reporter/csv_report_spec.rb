# frozen_string_literal: true

require "decidim/backports_reporter/csv_report"

describe Decidim::BackportsReporter::CSVReport do
  subject { described_class.new(report:, last_version_number:).call }

  let(:report) do
    [{ id: 1234, title: "Fix the world", related_issues: [] }]
  end
  let(:last_version_number) { "0.27" }

  describe ".call" do
    context "without related_issues" do
      it "returns a valid response" do
        expect(subject).to eq "ID;Title;Backport v0.27;Backport v0.26\n1234;Fix the world;;\n"
      end
    end

    context "with another version number" do
      let(:last_version_number) { "0.31" }

      it "returns a valid response" do
        expect(subject).to eq "ID;Title;Backport v0.31;Backport v0.30\n1234;Fix the world;;\n"
      end
    end

    context "with related_issues" do
      context "when it is not a backport" do
        let(:report) do
          [{ id: 1234, title: "Fix the world", related_issues: [id: 9876, title: "Whatever", state: "closed"] }]
        end

        it "returns a valid response" do
          expect(subject).to eq "ID;Title;Backport v0.27;Backport v0.26\n1234;Fix the world;;\n"
        end
      end

      context "when it is a backport" do
        let(:report) do
          [{ id: 1234, title: "Fix the world", related_issues: [id: 9876, title: 'Backport "Fix the world" to v0.26', state: "merged"] }]
        end

        it "returns a valid response" do
          expect(subject).to eq "ID;Title;Backport v0.27;Backport v0.26\n1234;Fix the world;;merged|9876\n"
        end
      end
    end
  end
end
