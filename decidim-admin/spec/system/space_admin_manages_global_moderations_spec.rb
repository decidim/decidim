# frozen_string_literal: true

require "spec_helper"

describe "Space admin manages global moderations", type: :system do
  let!(:user) do
    create(
      :process_admin,
      :confirmed,
      organization: organization,
      participatory_process: participatory_space
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let(:participatory_space) { current_component.participatory_space }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.root_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when the user can visualize the components" do
    let!(:reportable) { create(:dummy_resource, component: current_component, title: { "en" => "<p>Dummy<br> Title</p>" }) }
    let!(:moderation) { create(:moderation, reportable: reportable) }

    it "can see links to components" do
      visit decidim_admin.moderations_path

      within "body", wait: 2 do
        expect(page).to have_content("Moderations")
        expect(page).to have_link("Visit URL")

        find_link("Visit URL").hover
        expect(page).to have_content("Dummy Title")

        tooltip_id = find_link("Visit URL")["data-toggle"]
        result = page.find("##{tooltip_id}", visible: :all)
        expect(result).to have_content("Dummy Title")
      end
    end
  end

  context "when the user can manage a space that has moderations" do
    it_behaves_like "manage moderations" do
      let(:moderations_link_text) { "Global moderations" }
    end
  end

  context "when the user can manage a space without moderations" do
    let(:participatory_space) do
      create :participatory_process, organization: organization
    end

    it "can't see any moderation" do
      visit decidim_admin.moderations_path

      within ".container" do
        expect(page).to have_content("Moderations")

        expect(page).to have_no_selector("table.table-list tbody tr")
      end
    end
  end
end
