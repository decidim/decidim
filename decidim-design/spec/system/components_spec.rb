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

  # TBD: fix `No route matches [GET] "/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg"` exception
  #
  # context "when on activities page" do
  #   it_behaves_like "showing the design page", "Activities", "LastActivity"
  # end

  # TBD: fix `No route matches [GET] "/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg"` exception
  #
  # context "when on adddress page" do
  #   it_behaves_like "showing the design page", "Address", "geolocalizable"
  # end

  context "when on announcement page" do
    it_behaves_like "showing the design page", "Announcement", "secondary color"
  end

  # TBD: fix `No route matches [GET] "/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg"` exception
  #
  # context "when on author page" do
  #   it_behaves_like "showing the design page", "Author", "Hovering with the mouse"
  # end

  context "when on buttons page" do
    it_behaves_like "showing the design page", "Buttons", "button__xs"
  end

  # TBD: fix `No route matches [GET] "/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg"` exception
  #
  # context "when on cards page" do
  #   it_behaves_like "showing the design page", "Cards", "Variations"
  # end

  context "when on dialogs page" do
    it_behaves_like "showing the design page", "Dialogs", "Show modal"
  end

  context "when on dropdowns page" do
    it_behaves_like "showing the design page", "Dropdowns", "a11y-dropdown-component"
  end

  # TBD: fix `No route matches [GET] "/decidim-packs/media/images/remixicon.symbol-e643e553623ffcd49f94.svg"` exception
  #
  # context "when on follow page" do
  #   it_behaves_like "showing the design page", "Follow", "login_modal"
  # end

  context "when on forms page" do
    it_behaves_like "showing the design page", "Forms", "date, datetime-local, email"
  end

  # TBD: fix `ActionView::Template::Error: undefined method `reported_by?' for nil:NilClass` exception
  #
  # context "when on report page" do
  #   it_behaves_like "showing the design page", "Report", "modal window"
  # end

  context "when on share page" do
    it_behaves_like "showing the design page", "Share", "share_modal"
  end

  context "when on tab panels page" do
    it_behaves_like "showing the design page", "Tab Panels", "layout_item"
  end
end
