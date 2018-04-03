# frozen_string_literal: true

require "spec_helper"

describe "index", type: :system do
  include_context "when managing a component as an admin"

  let(:manifest_name) { "sortitions" }
  let!(:sortition) { create(:sortition, component: current_component) }

  before do
    visit_component_admin
  end

  it "Contains a new button" do
    expect(page).to have_link("New")
  end

  it "Contains a button that shows sortition details" do
    expect(page).to have_link("Sortition details")
  end

  it "Contains the sortitions data" do
    expect(page).to have_content(sortition.title[:en])
    expect(page).to have_content(sortition.reference)
  end
end
