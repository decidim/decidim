# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      module Censuses
        describe InternalUsersForm do
          let(:organization) { create(:organization) }
          let(:valid_verification_handlers) { %w(email_authorization phone_authorization) }

          subject do
            described_class.from_params(
              verification_handlers: verification_handlers
            ).with_context(current_organization: organization)
          end

          before do
            allow(organization).to receive(:available_authorizations).and_return(valid_verification_handlers)
          end

          context "when verification_handlers are valid" do
            let(:verification_handlers) { ["email_authorization"] }

            it { is_expected.to be_valid }

            it "returns the correct census_settings" do
              expect(subject.census_settings).to eq({ verification_handlers: verification_handlers })
            end
          end

          context "when verification_handlers are blank" do
            let(:verification_handlers) { [] }

            it { is_expected.to be_valid }

            it "returns empty census_settings" do
              expect(subject.census_settings).to eq({ verification_handlers: [] })
            end
          end

          context "when verification_handlers contain invalid types" do
            let(:verification_handlers) { ["invalid_type"] }

            it "is not valid and adds an error" do
              expect(subject).not_to be_valid
              expect(subject.errors[:verification_handlers]).to be_present
            end
          end
        end
      end
    end
  end
end
