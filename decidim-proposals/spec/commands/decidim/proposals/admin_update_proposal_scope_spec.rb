# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposalScope do
        describe "call" do
          let!(:proposal) { create :proposal }
          let!(:proposals) { create_list(:proposal, 3, component: proposal.component) }
          let!(:scope_one) { create :scope, organization: proposal.organization }
          let!(:scope) { create :scope, organization: proposal.organization }

          context "with no scope" do
            it "broadcasts invalid_scope" do
              expect { described_class.call(nil, proposal.id) }.to broadcast(:invalid_scope)
            end
          end

          context "with no proposals" do
            it "broadcasts invalid_proposal_ids" do
              expect { described_class.call(scope.id, nil) }.to broadcast(:invalid_proposal_ids)
            end
          end

          describe "with a scope and proposals" do
            context "when the scope is the same as the proposal's scope" do
              before do
                proposal.update!(scope:)
              end

              it "doesn't update the proposal" do
                expect(proposal).not_to receive(:update!)
                described_class.call(proposal.scope.id, proposal.id)
              end
            end

            context "when the scope is diferent from the proposal's scope" do
              before do
                proposals.each { |p| p.update!(scope: scope_one) }
              end

              it "broadcasts update_proposals_scope" do
                expect { described_class.call(scope.id, proposals.pluck(:id)) }.to broadcast(:update_proposals_scope)
              end

              it "updates the proposal" do
                described_class.call(scope.id, proposal.id)

                expect(proposal.reload.scope).to eq(scope)
              end
            end
          end
        end
      end
    end
  end
end
