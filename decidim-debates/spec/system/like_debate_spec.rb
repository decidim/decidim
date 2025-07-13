# frozen_string_literal: true

require "spec_helper"

describe "Like debates" do
  include_context "with resources to be liked or not"

  let(:manifest_name) { "debates" }
  let!(:resources) { create_list(:debate, 3, component:) }
  let!(:resource) { resources.first }
  let!(:resource_name) { translated(resource.title) }
  let!(:component) do
    create(:debates_component,
           *component_traits,
           manifest:,
           participatory_space: participatory_process)
  end

  it_behaves_like "Like resource system specs"
end
