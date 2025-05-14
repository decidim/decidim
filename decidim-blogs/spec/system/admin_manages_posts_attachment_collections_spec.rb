# frozen_string_literal: true

require "spec_helper"

describe "Admin manages posts attachment collections" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let!(:post) { create(:post, component: current_component, title: { en: "Post title 1" }, author: user) }

  before do
    component_settings = current_component["settings"]["global"].merge!(attachments_allowed: true)
    current_component.update!(settings: component_settings)
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage posts attachment collections"
end
