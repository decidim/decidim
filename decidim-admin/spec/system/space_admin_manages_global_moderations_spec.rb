# frozen_string_literal: true

require "spec_helper"

describe "Space admin manages global moderations" do
  let!(:user) do
    create(
      :process_admin,
      :confirmed,
      organization:,
      participatory_process: participatory_space
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create(:component) }
  let(:participatory_space) { current_component.participatory_space }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.root_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user has not accepted the admin TOS" do
    before do
      user.update(admin_terms_accepted_at: nil)
      visit decidim_admin.moderations_path
    end

    it "has a message that they need to accept the admin TOS" do
      expect(page).to have_content("Please take a moment to review the admin terms of service")
    end

    it "has the main navigation not empty" do
      within ".layout-nav" do
        expect(page).to have_no_css("li a")
      end
    end

    context "when they visit other admin pages" do
      before do
        visit decidim_admin.newsletters_path
      end

      it "says that you are not authorized" do
        expect(page).to have_text("Please take a moment to review the admin terms of service")
      end
    end
  end

  context "when the user can visualize the components" do
    let!(:reportable) { create(:dummy_resource, component: current_component, title: { "en" => "<p>Dummy<br> Title</p>" }) }
    let!(:moderation) { create(:moderation, reportable:) }

    it "can see links to components" do
      visit decidim_admin.moderations_path

      within "body", wait: 2 do
        expect(page).to have_content("Reported content")
        expect(page).to have_link("Visit URL")

        find_link("Visit URL").hover
        expect(page).to have_content("Dummy Title")
      end
    end
  end

  context "when the user can manage a space that has moderations" do
    it_behaves_like "manage moderations" do
      let(:moderations_link_text) { "Global moderations" }
      let(:moderations_link_in_admin_menu) { false }
    end

    it_behaves_like "sorted moderations" do
      let!(:reportables) { create_list(:dummy_resource, 27, component: current_component) }
      let(:moderations_link_text) { "Global moderations" }
      let(:moderations_link_in_admin_menu) { false }
    end
  end

  context "when the user can manage a space without moderations" do
    let(:participatory_space) do
      create(:participatory_process, organization:)
    end

    it "cannot see any moderation" do
      visit decidim_admin.moderations_path

      within "[data-content]" do
        expect(page).to have_content("Reported content")

        expect(page).to have_no_css("table.table-list tbody tr")
      end
    end
  end
end
