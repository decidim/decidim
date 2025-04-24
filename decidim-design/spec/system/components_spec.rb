# frozen_string_literal: true

require "spec_helper"

describe "Components" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, organization:) }

  before do
    switch_to_host(organization.host)
    visit decidim_design.root_path
  end

  context "when on accordions page" do
    it_behaves_like "showing the design page", "Accordions", "a11y-accordion-component"
  end

  context "when on activities page" do
    let(:participatory_space) { create(:participatory_process, :published, organization:) }
    let(:component) { create(:component, :published, participatory_space:) }
    let!(:action_log) do
      create(:action_log, created_at: 1.day.ago, action: "publish", visibility: "public-only", resource: participatory_space, organization:, component:, participatory_space: nil)
    end

    it_behaves_like "showing the design page", "Activities", "LastActivity"
  end

  context "when on address page" do
    it_behaves_like "showing the design page", "Address", "geolocalizable"
  end

  context "when on announcement page" do
    it_behaves_like "showing the design page", "Announcement", "secondary color"
  end

  context "when on buttons page" do
    it_behaves_like "showing the design page", "Buttons", "button__xs"
  end

  context "when on cards page" do
    it_behaves_like "showing the design page", "Cards", "Variations"
  end

  context "when on dialogs page" do
    it_behaves_like "showing the design page", "Dialogs", "Show modal"
  end

  context "when on dropdowns page" do
    it_behaves_like "showing the design page", "Dropdowns", "a11y-dropdown-component"
  end

  context "when on follow page" do
    it_behaves_like "showing the design page", "Follow", "login_modal"
  end

  context "when on forms page" do
    it_behaves_like "showing the design page", "Forms", "date, datetime-local, email"
  end

  context "when on report page" do
    it_behaves_like "showing the design page", "Report", "modal window"
  end

  context "when on share page" do
    it_behaves_like "showing the design page", "Share", "share_modal"
  end

  context "when on tab panels page" do
    it_behaves_like "showing the design page", "Tab Panels", "layout_item"
  end

  context "when on tooltips page" do
    it_behaves_like "showing the design page", "Tooltips", "top"
  end
end
