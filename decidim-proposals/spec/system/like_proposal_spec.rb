# frozen_string_literal: true

require "spec_helper"

describe "Like Proposal" do
  include_context "with resources to be liked or not"

  let(:manifest_name) { "proposals" }
  let!(:resources) { create_list(:proposal, 3, component:) }
  let!(:resource) { resources.first }
  let!(:resource_name) { translated(resource.title) }
  let!(:component) do
    create(:proposal_component,
           *component_traits,
           manifest:,
           participatory_space: participatory_process)
  end

  it_behaves_like "Like resource system specs"
end
