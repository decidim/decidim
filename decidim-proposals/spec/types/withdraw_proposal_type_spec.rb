# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe WithdrawProposalType, type: :graphql do
      include_context "with a graphql class mutation"

      let(:root_klass) { ProposalMutationType }
      let(:current_organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_process) { create(:participatory_process, :with_steps, organization: current_organization) }
      let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:author) { create(:user, :confirmed, organization: current_organization) }
      let!(:model) { create(:proposal, component: proposal_component, users: [author]) }
      let(:component) { model.component }
      let(:query) do
        <<~GRAPHQL
          mutation() {
            withdraw(input: {}) {
              id
              state
              withdrawnAt
            }
          }
        GRAPHQL
      end

      let(:variables) do
        {
          input: {
            attributes: {}
          }
        }
      end

      describe "withdrawing a proposal" do
        context "with proposal author" do
          let(:current_user) { author }
          let(:user_type) { :user }

          it "withdraws the proposal" do
            proposal = response["withdraw"]
            expect(proposal).to be_present
            expect(proposal["id"]).to eq(model.id.to_s)
            expect(model.reload).to be_withdrawn
            expect(model.withdrawn_at).to be_present
          end
        end

        context "with admin user" do
          let!(:user_type) { :admin }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "with api_user that is not the author" do
          let!(:user_type) { :api_user }

          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "with normal user that is not the author" do
          it "raises a Decidim::Api::Errors::MutationNotAuthorizedError exception" do
            expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          end
        end

        context "with api_user that is the author" do
          let!(:model) { create(:proposal, component: proposal_component, users: [current_user]) }
          let!(:user_type) { :api_user }

          it "withdraws the proposal" do
            proposal = response["withdraw"]
            expect(proposal).to be_present
            expect(proposal["id"]).to eq(model.id.to_s)
            expect(model.reload).to be_withdrawn
            expect(model.withdrawn_at).to be_present
          end
        end
      end

      context "when proposal has votes" do
        let(:current_user) { author }

        before do
          model.votes.create!(author: create(:user, :confirmed, organization: current_organization))
        end

        it "does not withdraw the proposal and returns an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::ValidationError, "This proposal cannot be withdrawn because it already has votes.")
          expect(model.reload).not_to be_withdrawn
          expect(model.withdrawn_at).not_to be_present
        end
      end

      context "when proposal is already withdrawn" do
        let!(:model) { create(:proposal, :withdrawn, component: proposal_component, users: [author]) }
        let(:current_user) { author }

        it "remains withdrawn and returns an error" do
          expect { response }.to raise_error(Decidim::Api::Errors::MutationNotAuthorizedError, "You do not have permission to perform this mutation")
          expect(model.reload).to be_withdrawn
          expect(model.withdrawn_at).to be_present
        end
      end

      context "when proposal is already answered" do
        let!(:model) { create(:proposal, :with_answer, component: proposal_component, users: [author]) }
        let(:current_user) { author }

        it "can be withdrawn by author" do
          proposal = response["withdraw"]
          expect(proposal).to be_present
          expect(proposal["id"]).to eq(model.id.to_s)
          expect(model.reload).to be_withdrawn
          expect(model.withdrawn_at).to be_present
        end
      end
    end
  end
end
