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
        organization:,
        current_user:,
        invalid?: invalid
      )
    end
    let(:invalid) { false }

    context "when the form is valid" do
      let(:census_data) { Decidim::Verifications::CsvDatum.last }

      it "creates a new census record" do
        expect { subject.call }.to change(Decidim::Verifications::CsvDatum, :count).by(1)
      end

      it "sets the email" do
        subject.call
        expect(census_data.email).to eq email
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::Verifications::CsvDatum, current_user, {})
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.action).to eq("create")
        expect(action_log.version).to be_present
      end
    end

    context "when the form is invalid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
