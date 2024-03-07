# frozen_string_literal: true

require "spec_helper"

shared_examples "an uncommentable component" do
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end

  it "does not displays comments count" do
    component.update!(settings: { comments_enabled: false })

    visit_component

    resources.each do |resource|
      expect(page).to have_no_link(resource_locator(resource).path)
    end
  end
end
