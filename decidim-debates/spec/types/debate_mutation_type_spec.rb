# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/mutation_context"

module Decidim
  module Debates
    describe CloseDebateType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { DebateMutationType }
      let(:organization) { current_organization }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
      let(:debates_component) { create(:component, manifest_name: :debates, participatory_space: participatory_process) }
      let(:author) { current_user }
      let!(:model) { create(:debate, component: debates_component, author:) }
      let(:conclusions) { ::Faker::Lorem.sentence(word_count: 15) }
      let(:component) { model.component }
      let(:locale) { "en" }
      let(:variables) do
        {
          input: {
            locale:,
            attributes: {
              conclusions:
            }
          }
        }
      end
      let(:query) do
        <<~GRAPHQL
          mutation($input: CloseDebateInput!) {
            close(input: $input) {
              id
              conclusions { translation(locale: "en") }
              closedAt
            }
          }
        GRAPHQL
      end

      shared_examples "close debate mutation examples" do
        context "when user cannot close the debate" do
          let!(:author) { create(:user, :confirmed, organization: current_organization) }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "when user can close the debate" do
          it "closes the debate" do
            closed = response["close"]
            expect(closed).to be_present
            expect(closed).to include(
              {
                "id" => model.id.to_s,
                "conclusions" => {
                  "translation" => conclusions
                },
                "closedAt" => model.reload.closed_at.to_time.iso8601
              }
            )
          end
        end

        context "when validating" do
          context "when debate is hidden" do
            let!(:model) { create(:debate, :hidden, component: debates_component, author:) }

            it "raises a Decidim::Api::Errors::UnauthorizedObjectError" do
              expect { response }.to raise_error(Decidim::Api::Errors::UnauthorizedObjectError, "You cannot view or edit this Debate because you do not have permissions")
            end
          end

          context "when debate is closed" do
            let!(:model) { create(:debate, :closed, component: debates_component, author:) }

            it "raises a Decidim::Api::Errors::MutationNotAuthorizedError" do
              expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
            end
          end

          context "when conclusions are empty" do
            let(:conclusions) { "" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /cannot be blank/)
            end
          end

          context "when conclusions are too short" do
            let(:conclusions) { "Short" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::AttributeValidationError, /is too short/)
            end
          end

          context "with invalid locale" do
            let(:locale) { "tlh" }

            it "raises an error" do
              expect { response }.to raise_error(Decidim::Api::Errors::InvalidLocaleError, /Invalid locale provided/)
            end
          end
        end
      end

      context "with admin user" do
        let!(:user_type) { :admin }

        it_behaves_like "close debate mutation examples"
      end

      context "with debate author" do
        let!(:user_type) { :user }

        it_behaves_like "close debate mutation examples"
      end

      context "with api_user" do
        let!(:user_type) { :api_user }

        it_behaves_like "close debate mutation examples"
      end
    end
  end
end
