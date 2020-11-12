# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatorySpaceResources do
  subject { described_class.new(participatory_process) }

  let!(:participatory_process) { create(:participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, :official, component: proposal_component) }
  let!(:second_proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:second_proposal) { create(:proposal, :official, component: proposal_component) }

  let!(:another_participatory_process) { create(:participatory_process) }
  let!(:meeting_component) { create(:meeting_component, participatory_space: another_participatory_process) }
  let!(:meeting) { create(:meeting, component: meeting_component) }

  it "returns the resources for the participatory space" do
    expect(subject.query).to match [proposal, second_proposal]
  end
end
