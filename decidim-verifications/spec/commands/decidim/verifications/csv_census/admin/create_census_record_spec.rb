# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications
  describe CsvCensus::Admin::CreateCensusRecord do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:email) { "test@example.org" }
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    let(:form) do
      double(
        email:,
        current_organization: organization,
        current_user:,
        invalid?: invalid
      )
    end
    let(:invalid) { false }

    context "when the form is valid" do
      it "enqueues the job to process census data" do
        expect(Decidim::Verifications::CsvCensus::ProcessCensusDataJob).to receive(:perform_now)
          .with([email], organization)

        subject.call
      end

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end
    end

    context "when the form is invalid" do
      let(:invalid) { true }

      it "does not enqueue the job" do
        expect(Decidim::Verifications::CsvCensus::ProcessCensusDataJob).not_to receive(:perform_now)
        subject.call
      end

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
