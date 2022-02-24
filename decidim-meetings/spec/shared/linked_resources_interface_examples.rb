# frozen_string_literal: true

require "spec_helper"

shared_examples_for "linked resources interface" do
  describe "proposals_from_meeting" do
    let(:query) { "{ proposalsFromMeeting { id } }" }
    let(:linked_proposals) { create_list(:proposal, 3, component: proposal_component) }
    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: model.component.participatory_space)
    end
    let(:moderation) { create(:moderation, reportable: linked_proposals.last) }

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

      it "hides the moderated proposals" do
        moderation.update(hidden_at: Time.current)

        ids = response["proposalsFromMeeting"].map { |item| item["id"] }
        expect(ids).not_to include(linked_proposals.last.id.to_s)
      end
    end
  end
end
