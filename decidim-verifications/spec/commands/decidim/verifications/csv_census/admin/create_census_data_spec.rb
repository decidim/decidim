# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CreateCensusData do
    subject { described_class.new(form, current_user) }

    let(:organization) { create(:organization) }
    let(:file) do
      Tempfile.new(["test", ".csv"]).tap do |file|
        file.write("valid_email@example.com\nanother_valid_email@example.com")
        file.rewind
      end
    end
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    let(:form) { instance_double(CensusDataForm, file:, data:) }
    let(:data) { instance_double(Decidim::Verifications::CsvCensus::Data, values: ["valid_email@example.com", "another_valid_email@example.com"]) }

    before do
      allow(form).to receive(:data).and_return(data)
      allow(Decidim::Verifications::CsvDatum).to receive(:insert_all)
      allow(Decidim::Verifications::CsvCensus::ProcessCensusDataJob).to receive(:perform_later)
    end

    context "when the file is in invalid format" do
      let(:file) do
        Tempfile.new(["invalid_format", ".csv"]).tap do |file|
          file.write("invalid,email@format\nnot_an_email")
          file.rewind
        end
      end
      let(:data) { instance_double(Decidim::Verifications::CsvCensus::Data, values: [], errors: ["Invalid format"]) }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the file is valid" do
      it "inserts all emails into the database" do
        expect { subject.call }.not_to raise_error
        expect(Decidim::Verifications::CsvDatum).to have_received(:insert_all).with(organization, ["valid_email@example.com", "another_valid_email@example.com"])
      end

      it "enqueues the ProcessCensusDataJob" do
        subject.call
        expect(Decidim::Verifications::CsvCensus::ProcessCensusDataJob).to have_received(:perform_later).with(["valid_email@example.com", "another_valid_email@example.com"], current_user)
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
