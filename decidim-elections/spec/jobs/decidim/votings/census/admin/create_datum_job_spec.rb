# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Census::Admin::CreateDatumJob do
  let!(:dataset) { create(:dataset) }
  let(:user) { create(:user, :admin, organization: dataset.voting.organization) }
  let!(:csv_row) { ["12345678X", "DNI", "20011202", "John Doe", "The full address one", "08001", "123456789", "user@example.org", "BS1"] }

  describe "queue" do
    it "is queued to events" do
      expect(described_class.queue_name).to eq "default"
    end
  end

  describe "perform" do
    it "delegates the work to a command" do
      expect(Decidim::Votings::Census::Admin::CreateDatum).to receive(:call)

      described_class.perform_now(user, dataset, csv_row)
    end

    context "when the dataset is missing" do
      let!(:dataset) { nil }
      let(:user) { create(:user, :admin) }

      it "does not create a datum" do
        expect(Decidim::Votings::Census::Admin::CreateDatum).not_to receive(:call)

        described_class.perform_now(user, dataset, csv_row)
      end
    end

    context "when the user is missing" do
      let!(:user) { nil }

      it "does not create a datum" do
        expect(Decidim::Votings::Census::Admin::CreateDatum).not_to receive(:call)

        described_class.perform_now(user, dataset, csv_row)
      end
    end

    context "when the csv_row is missing" do
      let!(:csv_row) { nil }

      it "does not create a datum" do
        expect(Decidim::Votings::Census::Admin::CreateDatum).not_to receive(:call)

        described_class.perform_now(user, dataset, csv_row)
      end
    end
  end
end
