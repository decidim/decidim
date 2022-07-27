# frozen_string_literal: true

require "spec_helper"

shared_examples "an uncommentable component" do
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end

  it "doesn't displays comments count" do
    component.update!(settings: { comments_enabled: false })

    visit_component

    resources.each do |ressource|
      expect(page).not_to have_link(resource_locator(ressource).path)
    end
  end
end
