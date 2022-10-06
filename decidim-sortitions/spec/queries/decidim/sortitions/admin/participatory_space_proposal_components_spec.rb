# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe ParticipatorySpaceProposalComponents do
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:proposal_components) { create_list(:proposal_component, 10, participatory_space: participatory_process) }
        let(:unpublished_proposal_components) { create_list(:proposal_component, 10, participatory_space: participatory_process, published_at: nil) }
        let(:sortition_components) { create_list(:sortition_component, 10, participatory_space: participatory_process) }

        it "returns proposal components in the participatory space" do
          expect(described_class.for(participatory_process)).to include(*proposal_components)
        end

        it "Do not include unpublished proposal components" do
          expect(described_class.for(participatory_process)).not_to include(*unpublished_proposal_components)
        end

        it "do not return other components in participatory space" do
          expect(described_class.for(participatory_process)).not_to include(*sortition_components)
        end
      end
    end
  end
end
