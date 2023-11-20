# frozen_string_literal: true

require "spec_helper"

describe "Foundations" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim_design.root_path
  end

  context "when on accessibility page" do
    it_behaves_like "showing the design page", "Accessibility", "Web Content Accessibility Guidelines (WCAG) 2.1"
  end

  # TBD: fix `undefined method `cards_table' for` exception
  #
  # context "when on color page" do
  #   it_behaves_like "showing the design page", "Color", "primary"
  # end

  context "when on iconography page" do
    it_behaves_like "showing the design page", "Iconography", "Remixicon"
  end

  context "when on typoography page" do
    it_behaves_like "showing the design page", "Typography", "Source Sans Pro"
  end
end
