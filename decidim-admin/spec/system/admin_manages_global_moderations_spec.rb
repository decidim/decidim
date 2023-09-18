# frozen_string_literal: true

require "spec_helper"

describe "Admin manages global moderations", type: :system do
  let!(:user) do
    create(
      :user,
      :confirmed,
      :admin,
      organization: organization
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create :component }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.moderations_path
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when on hidden moderations path" do
    let!(:hidden_moderations) do
      moderation = create(:moderation, reportable: reportables.last, report_count: 3, reported_content: reportables.last.reported_searchable_content_text, hidden_at: Time.current)
      create_list(:report, 3, moderation: moderation, reason: :spam)
      [moderation]
    end
    let!(:hidden_moderation) { hidden_moderations.first }

    before do
      visit decidim_admin.moderations_path(hidden: true)
    end

    it "can be filtering by id" do
      search = hidden_moderation.reportable.id
      within ".filters__section" do
        fill_in("Search Moderation by reportable id or content.", with: search)
        find(:xpath, "//button[@type='submit']").click
      end
      expect(page).to have_selector("tbody tr", count: 1)
    end
  end
end
