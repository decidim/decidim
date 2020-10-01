# frozen_string_literal: true

require "spec_helper"

describe "Admin manages trustees", type: :system do
  let(:trustee) { create :trustee, :considered }
  let!(:participatory_space) { create :participatory_process }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_trustees
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
          :trustees_participatory_spaces,
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
      expect(page).to have_css(".pagination .page", count: 2)
      click_link "Next"

      expect(page).to have_selector(".pagination .current", text: "2")

      expect(page).to have_css(resource_selector, count: 5)
    end
  end

  def visit_trustees
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_space)
  end
end
