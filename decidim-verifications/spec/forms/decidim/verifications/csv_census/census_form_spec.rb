# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Verifications
    module CsvCensus
      describe CensusForm do
        subject do
          described_class.from_params(
            user:
          ).with_context(
            context
          )
        end

        let(:user) { create(:user) }
        let(:email) { user.email }
        let(:organization) { user.organization }
        let(:csv_datum) { create(:csv_datum, email:, organization:) }

        let(:context) do
          {
            current_organization: organization
          }
        end

        before do
          csv_datum
        end

        context "when user email in census" do
          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "when user email not in census" do
          let(:csv_datum) { create(:csv_datum, email: "other_email@example.org", organization:) }

          it "is not valid" do
            expect(subject).not_to be_valid
          end
        end
      end
    end
  end
end
