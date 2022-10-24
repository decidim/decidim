# frozen_string_literal: true

require "spec_helper"

describe "Endorse Proposal", type: :system do
  include_context "with resources to be endorsed or not"

  let(:manifest_name) { "proposals" }
  let!(:resources) { create_list(:proposal, 3, component:, skip_injection: true) }
  let!(:resource) { resources.first }
  let!(:resource_name) { translated(resource.title) }
  let!(:component) do
    create(:proposal_component,
           *component_traits,
           manifest:,
           participatory_space: participatory_process)
  end

  it_behaves_like "Endorse resource system specs"
end
