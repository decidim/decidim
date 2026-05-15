# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Admin
      module Censuses
        describe InternalUsersForm do
          let(:organization) { create(:organization) }
          let(:valid_authorization_handlers) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
          let(:authorization_handlers) do
            {
              "dummy_authorization_handler" => {},
              "another_dummy_authorization_handler" => {}
            }
          end
          let(:authorization_handlers_names) { [] }
          let(:authorization_handlers_options) do
            {
              "dummy_authorization_handler" => { "allowed_postal_codes" => "08001" }
            }
          end

          subject do
            described_class.from_params(
              authorization_handlers:,
              authorization_handlers_names:,
              authorization_handlers_options:
            ).with_context(current_organization: organization)
          end

          before do
            allow(organization).to receive(:available_authorizations).and_return(valid_authorization_handlers)
          end

          context "when authorization_handlers are valid" do
            it { is_expected.to be_valid }

            it "returns the correct census_settings" do
              expect(subject.census_settings).to eq({ authorization_handlers: {
                                                      "dummy_authorization_handler" => { options: { "allowed_postal_codes" => "08001" } },
                                                      "another_dummy_authorization_handler" => { options: {} }
                                                    } })
            end
          end

          context "when authorization_handlers are blank" do
            let(:authorization_handlers) { nil }

            it { is_expected.to be_valid }

            it "returns empty census_settings" do
              expect(subject.census_settings).to eq({ authorization_handlers: {} })
            end
          end

          context "when authorization_handlers contain invalid types" do
            let(:authorization_handlers) { { "invalid_handler" => {} } }

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
