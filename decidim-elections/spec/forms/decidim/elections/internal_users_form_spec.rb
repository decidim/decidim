# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Elections
    module Censuses
      describe InternalUsersForm do
        let(:user) { create(:user, :confirmed, organization:) }
        let(:election) { create(:election, :ongoing, :with_internal_users_census, census_settings:) }
        let(:organization) { election.organization }
        let(:census_settings) do
          {
            "authorization_handlers" => authorization_handlers
          }
        end
        let(:authorization_handlers) do
          {}
        end

        before do
          organization.update!(available_authorizations: %w(dummy_authorization_handler))
        end

        subject { described_class.new.with_context(election:, current_user: user) }

        it { is_expected.to be_valid }

        describe "#voter_uid" do
          it "returns the global ID of the user in the census" do
            expect(subject.voter_uid).to eq(user.to_global_id.to_s)
          end
        end

        context "when the user is not in the census" do
          let(:user) { create(:user, :confirmed) }

          it { is_expected.not_to be_valid }

          it "returns nil" do
            expect(subject.voter_uid).to be_nil
          end
        end

        context "when a verification handler is required" do
          let(:authorization_handlers) do
            {
              "dummy_authorization_handler" => { "options" => options }
            }
          end
          let(:options) { {} }

          it "returns the required authorizations" do
            expect(subject.adapters.map(&:name)).to eq(["dummy_authorization_handler"])
          end

          it { is_expected.not_to be_valid }

          it "voter uid returns nil" do
            expect(subject.voter_uid).to be_nil
          end

          context "when the user has the required authorizations" do
            let!(:authorization) { create(:authorization, :granted, user:, organization:, name: "dummy_authorization_handler") }

            it { is_expected.to be_valid }

            it "voter uid returns the user's global ID" do
              expect(subject.voter_uid).to eq(user.to_global_id.to_s)
            end

            context "when the authorization has options" do
              let(:options) { { "allowed_postal_codes" => "08002" } }

              it "returns the options in the census settings" do
                expect(subject.authorization_handlers["dummy_authorization_handler"]["options"]).to eq(options)
              end

              it { is_expected.not_to be_valid }

              it "adds an error for the base" do
                subject.validate
                expect(subject.errors[:base]).to include(I18n.t("decidim.elections.censuses.internal_users_form.invalid"))
                expect(subject.authorization_status).to be_a(Decidim::ActionAuthorizer::AuthorizationStatusCollection)
                expect(subject.authorization_status).not_to be_ok
                expect(subject.authorization_status.statuses.first.data).to eq({ :extra_explanation => [{ :key => "extra_explanation.postal_codes", :params => { :scope => "decidim.verifications.dummy_authorization", :count => 1, :postal_codes => "08002" } }] })
              end

              context "when the user does not match the options" do
                let!(:authorization) { create(:authorization, :granted, user:, organization:, name: "dummy_authorization_handler", metadata: { postal_code: "08001" }) }

                it { is_expected.not_to be_valid }
              end

              context "when the user matches the options" do
                let!(:authorization) { create(:authorization, :granted, user:, organization:, name: "dummy_authorization_handler", metadata: { postal_code: "08002" }) }

                it { is_expected.to be_valid }
              end
            end
          end
        end
      end
    end
  end
end
