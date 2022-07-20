# frozen_string_literal: true

require "spec_helper"

describe "Admin manages trustees", type: :system do
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
    click_link "Trustees"
  end

  context "without existing trustee" do
    it "creates a new trustee" do
      find(".card-title a.new").click

      within ".new_trustee" do
        autocomplete_select "#{user.name} (@#{user.nickname})", from: :user_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#trustees table" do
        expect(page).to have_content(user.name.to_s)
        expect(page).to have_content(user.email.to_s)
      end
    end
  end

  context "when paginating" do
    let!(:collection_size) { 20 }
    let!(:collection) do
      create_list(:trustee, collection_size) do |trustee|
        trustee.trustees_participatory_spaces << build(
          :trustees_participatory_space,
          participatory_space: participatory_space
        )
      end
    end

    let!(:resource_selector) { "#trustees tbody tr" }

    before do
      visit current_path
    end

    it "lists 15 trustees per page by default" do
      expect(page).to have_css(resource_selector, count: 15)
      expect(page).to have_css("[data-pages] [data-page]", count: 2)
      click_link "Next"

      expect(page).to have_selector("[data-pages] [data-page][aria-current='page']", text: "2")

      expect(page).to have_css(resource_selector, count: 5)
    end
  end

  context "when updating status" do
    let!(:trustees) do
      create_list(:trustee, 4) do |trustee|
        trustee.trustees_participatory_spaces << build(
          :trustees_participatory_space,
          participatory_space: participatory_space
        )
      end
    end

    before do
      visit current_path
    end

    it "toggles considered status" do
      first("a.action-icon--edit").click

      within "#trustees table" do
        expect(page).to have_content("inactive")
      end
    end
  end

  context "when removing trustee from participatory space" do
    let!(:trustee_participatory_space) { create :trustees_participatory_space, participatory_space: participatory_space }

    before do
      visit current_path
    end

    it "removes trustee" do
      accept_confirm do
        page.first("a.action-icon--remove").click
      end

      expect(page).to have_admin_callout("successfully")

      within "#trustees table" do
        expect(page).not_to have_content(trustee_participatory_space.trustee.user.name)
      end
    end
  end

  context "when inside an assembly" do
    let(:participatory_space) { create(:assembly, organization: organization) }

    it "shows the trustees page" do
      expect(page).to have_content("New Trustee")
    end
  end

  context "when inside a voting" do
    let(:participatory_space) { create(:voting, organization: organization) }

    it "shows the trustees page" do
      expect(page).to have_content("New Trustee")
    end
  end
end
