# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe UpdateProposalTaxonomies do
        describe "call" do
          let!(:resource) { create(:proposal) }
          let(:organization) { resource.organization }
          let!(:taxonomy_one) { create(:taxonomy, :with_parent, organization:) }
          let!(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
          let(:taxonomy_ids) { [taxonomy.id] }
          let(:proposal_ids) { [resource.id] }
          let(:command) { described_class.new(taxonomy_ids, proposal_ids, organization) }
          let(:resources) { Dev::DummyResource.where(id: resource.id) }

          subject { command.call }

          context "with no taxonomy" do
            let(:taxonomy_ids) { [] }

            it { is_expected.to broadcast(:invalid_taxonomies) }
          end

          context "with no resources" do
            let(:proposal_ids) { [] }

            it { is_expected.to broadcast(:invalid_resources) }
          end

          context "when the taxonomy is the same as the resource's taxonomy" do
            before do
              resource.update!(taxonomies: [taxonomy])
            end

            it "does not update the resource" do
              expect(resource).not_to receive(:update!)
              expect(subject).to broadcast(:update_resources_taxonomies)
            end
          end

          context "when the taxonomy is different from the resource's taxonomy" do
            before do
              resource.update!(taxonomies: [taxonomy_one])
            end

            it "updates the resource" do
              expect(subject).to broadcast(:update_resources_taxonomies)
              expect(resource.reload.taxonomies.first).to eq(taxonomy)
            end

            it "notifies the authors about the change on taxonomies" do
              expect(Decidim::EventsManager)
                .to receive(:publish)
                .with(
                  event: "decidim.events.proposals.proposal_update_taxonomies",
                  event_class: Decidim::Proposals::UpdateProposalTaxonomiesEvent,
                  resource:,
                  affected_users: resource.notifiable_identities
                )
              command.call
            end
          end
        end
      end
    end
  end
end
