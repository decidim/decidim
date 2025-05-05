# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::CsvCensus::Admin
  describe CensusForm do
    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    let(:attributes) { { email: } }

    subject do
      described_class.from_params(attributes).with_context(
        current_organization: organization,
        current_user:
      )
    end

    context "when there validations" do
      context "when email is blank" do
        let(:email) { nil }

        it "is invalid without an email" do
          expect(subject).to be_invalid
          expect(subject.errors[:email]).to include("cannot be blank")
        end
      end

      context "when email is present" do
        context "when email is unique" do
          let(:email) { "unique@example.com" }

          it "is valid with a unique email" do
            expect(subject).to be_valid
          end
        end

        context "when email is taken" do
          let(:email) { "taken@example.com" }

          before do
            create(:user, email:, organization:)
          end

          it "is not invalid with a taken email" do
            expect(subject).to be_valid
          end
        end
      end
    end
  end
end
