# frozen_string_literal: true

require "spec_helper"

shared_examples_for "linked resources interface" do
  describe "proposals_from_meeting" do
    let(:query) { "{ proposalsFromMeeting { id } }" }
    let(:linked_proposals) { create_list(:proposal, 3, component: proposal_component) }
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: model.component.participatory_space)
    end

    describe "when no proposals are linked" do
      it "does not include the services" do
        expect(response["proposalsFromMeeting"]).to eq([])
      end
    end

    describe "with some proposals linked" do
      before do
        model.link_resources(linked_proposals, "proposals_from_meeting")
      end

      it "includes the required data" do
        ids = response["proposalsFromMeeting"].map { |item| item["id"] }
        expect(ids).to include(*linked_proposals.map(&:id).map(&:to_s))
      end
    end
  end
end
