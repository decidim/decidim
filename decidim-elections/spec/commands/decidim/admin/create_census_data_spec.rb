# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      describe CreateCensusData do
        subject { command.call }

        let(:organization) { create(:organization) }
        let(:component) { create(:elections_component, organization:) }
        let(:election) { create(:election, component:) }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }

        let(:command) { described_class.new(form, election) }

        let(:file) { double("file") }
        let(:form) do
          CensusDataForm.new(file:).with_context(
            current_user:,
            current_component: component,
            current_organization: organization
          )
        end

        context "when the form has no file" do
          let(:file) { nil }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end
        end

        context "when the file is present but data is empty" do
          let(:file) { double("file", attached?: true, download: "email;token\n") }

          before do
            allow(CsvCensus::Data).to receive(:new).and_return(
              instance_double(CsvCensus::Data, values: [], errors: [])
            )
          end

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end
        end

        context "when file and data are valid" do
          let(:rows) { [%w(user1@example.org token1), %w(user2@example.org token2)] }
          let(:csv_data) { instance_double(CsvCensus::Data, values: rows, errors: []) }
          let(:file) { double("file", attached?: true, download: "email;token\nuser1@example.org;token1") }

          before do
            allow(CsvCensus::Data).to receive(:new).and_return(csv_data)
            allow(Decidim::Elections::Voter).to receive(:insert_all)
          end

          it "inserts voters and broadcasts ok" do
            expect(Decidim::Elections::Voter).to receive(:insert_all).with(election, rows)
            expect { subject }.to broadcast(:ok)
          end

          it "sets external census and clears verification types" do
            subject
            expect(election.reload).to be_external_census
            expect(election.verification_types).to eq([])
          end
        end
      end
    end
  end
end
