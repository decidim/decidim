# frozen_string_literal: true

shared_examples "going back to list button" do
  it "shows the back button" do
    expect(page).to have_link(href: main_component_path(component) + manifest_name)
  end

  context "when clicking the back button" do
    before do
      click_link(href: main_component_path(component) + manifest_name)
    end

    it "redirect the user to component index" do
      expect(page).to have_current_path(main_component_path(component) + manifest_name)
    end
  end
end
