# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CreateCensusData do
    subject { described_class.new(form, organization) }

    let(:organization) { create(:organization) }
    let(:file) do
      Tempfile.new(["test", ".csv"]).tap do |file|
        file.write("valid_email@example.com\nanother_valid_email@example.com")
        file.rewind
      end
    end
    let(:form) { instance_double(CensusDataForm, file:, data:) }
    let(:data) { instance_double(Decidim::Verifications::CsvCensus::Data, values: ["valid_email@example.com", "another_valid_email@example.com"]) }

    before do
      allow(form).to receive(:data).and_return(data)
      allow(Decidim::Verifications::CsvDatum).to receive(:insert_all)
      allow(Decidim::Verifications::CsvCensus::RemoveDuplicatesJob).to receive(:perform_later)
      allow(Decidim::Verifications::CsvCensus::AuthorizeExistingUsersJob).to receive(:perform_later)
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

      it "enqueues the RemoveDuplicatesJob" do
        subject.call
        expect(Decidim::Verifications::CsvCensus::RemoveDuplicatesJob).to have_received(:perform_later).with(organization)
      end

      it "enqueues the AuthorizeExistingUsersJob" do
        subject.call
        expect(Decidim::Verifications::CsvCensus::AuthorizeExistingUsersJob).to have_received(:perform_later).with(["valid_email@example.com", "another_valid_email@example.com"], organization)
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end
  end
end
