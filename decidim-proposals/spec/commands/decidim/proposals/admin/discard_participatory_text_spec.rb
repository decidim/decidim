# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe DiscardParticipatoryText do
        describe "call" do
          let(:current_component) do
            create(
              :proposal_component,
              participatory_space: create(:participatory_process)
            )
          end
          let(:proposals) do
            create_list(:proposal, 3, :draft, component: current_component)
          end
          let(:command) { described_class.new(current_component) }

          describe "when discarding" do
            it "removes all drafts" do
              expect { command.call }.to broadcast(:ok)
              proposals = Decidim::Proposals::Proposal.drafts.where(component: current_component)
              expect(proposals).to be_empty
            end
          end
        end
      end
    end
  end
end
