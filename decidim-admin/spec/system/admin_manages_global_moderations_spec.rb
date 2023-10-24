# frozen_string_literal: true

require "spec_helper"

describe "Admin manages global moderations", type: :system do
  let!(:user) do
    create(
      :user,
      :confirmed,
      :admin,
      organization:
    )
  end
  let(:organization) { current_component.organization }
  let(:current_component) { create(:component) }
  let!(:reportables) { create_list(:dummy_resource, 2, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin.moderations_path
  end
  let(:resource_controller) { Decidim::Admin::GlobalModerationsController }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  include_context "with filterable context"

  context "when displaying the counter" do
    let!(:reportables) { create_list(:dummy_resource, 4, component: current_component) }
    let!(:moderations) do
      reportables.first(3).map do |reportable|
        moderation = create(:moderation, reportable:, report_count: 1, reported_content: reportable.reported_searchable_content_text)
        create(:report, moderation:)
        moderation
      end
    end
    let!(:moderation) { moderations.first }
    let!(:hidden_moderations) do
      moderation = create(:moderation, reportable: reportables.last, report_count: 3, reported_content: reportables.last.reported_searchable_content_text, hidden_at: Time.current)
      create_list(:report, 3, moderation:, reason: :spam)
      [moderation]
    end

    it "displays the right count" do
      visit decidim_admin.moderations_path

      within_admin_sidebar_menu do
        expect(page).to have_css("span.component-counter", visible: :visible)
        expect(page).to have_css("span", text: (reportables.size - hidden_moderations.size))
      end
    end
  end

  context "when displaying the user counter" do
    let!(:reported_user) { create(:user, :confirmed, organization:) }
    let!(:moderation) { create(:user_moderation, user: reported_user, report_count: 1) }
    let!(:reportables) { create(:user_report, moderation:, user:, reason: "spam") }

    context "when displaying the user counter" do
      it "cannot see user menu counter for resources" do
        visit decidim_admin.moderations_path

        within_admin_sidebar_menu do
          expect(page).to have_css("span.component-counter--off", visible: :visible)
          expect(page).to have_css("span", text: "0")
        end
      end

      it "can see user menu counter" do
        visit decidim_admin.moderations_path

        within_admin_sidebar_menu do
          expect(page).to have_css("span.component-counter", visible: :visible, count: 2)
          expect(page).to have_css("span", text: "1")
        end
      end
    end
  end

  it "can see menu counter" do
    visit decidim_admin.moderations_path

    within_admin_sidebar_menu do
      expect(page).to have_css("span.component-counter", visible: :visible)
    end
  end

  it_behaves_like "manage moderations" do
    let(:moderations_link_text) { "Global moderations" }
    let(:moderations_link_in_admin_menu) { false }
  end

  it_behaves_like "sorted moderations" do
    let!(:reportables) { create_list(:dummy_resource, 17, component: current_component) }
    let(:moderations_link_text) { "Global moderations" }
    let(:moderations_link_in_admin_menu) { false }
  end

  context "when on hidden moderations path" do
    let!(:hidden_moderations) do
      moderation = create(:moderation, reportable: reportables.last, report_count: 3, reported_content: reportables.last.reported_searchable_content_text, hidden_at: Time.current)
      create_list(:report, 3, moderation:, reason: :spam)
      [moderation]
    end
    let!(:hidden_moderation) { hidden_moderations.first }

    before do
      visit decidim_admin.moderations_path(hidden: true)
    end

    it "can be filtered by id" do
      search_by_text(hidden_moderation.reportable.id)
      expect(page).to have_selector("tbody tr", count: 1)
    end
  end
end
