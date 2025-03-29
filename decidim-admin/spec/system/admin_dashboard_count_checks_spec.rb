# frozen_string_literal: true

require "spec_helper"

describe "Admin checks dashboard panel statistics" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  it "show users Activity panel" do
    expect(page).to have_content(t("decidim.admin.titles.statistics"))
    expect(page).to have_content(t("decidim.admin.users_statistics.users_count.participants"))
    expect(page).to have_content(t("decidim.admin.users_statistics.users_count.admins"))
  end

  it "show Admin log panel" do
    expect(page).to have_content(t("decidim.admin.titles.admin_log"))
  end

  context "when does not have Pending moderations" do
    it "hides the panel" do
      expect(page).to have_no_content(t("decidim.admin.dashboard.pending_moderations.title"))
      expect(page).to have_no_content(t("decidim.admin.dashboard.pending_moderations.goto_moderation"))
    end
  end

  context "when has Pending moderations" do
    context "when having reported resources" do
      let(:current_component) { create(:component) }
      let!(:reportable) { create(:dummy_resource, component: current_component, title: { "en" => "<p>Dummy<br> Title</p>" }) }
      let!(:moderation) { create(:moderation, reportable:) }
      let(:organization) { current_component.organization }

      before do
        visit decidim_admin.root_path
      end

      it "displays the panel" do
        expect(page).to have_content(t("decidim.admin.dashboard.pending_moderations.title"))
        expect(page).to have_content(t("decidim.admin.dashboard.pending_moderations.goto_moderation"))
      end
    end

    context "when having reported users" do
      let!(:reported_user) { create(:user, :confirmed, organization:) }
      let!(:moderation) { create(:user_moderation, user: reported_user, report_count: 1) }
      let!(:report) { create(:user_report, moderation:, user:, reason: "spam") }

      before do
        visit decidim_admin.root_path
      end

      it "displays the panel" do
        expect(page).to have_content(t("decidim.admin.dashboard.pending_moderations.title"))
        expect(page).to have_content(t("decidim.admin.dashboard.pending_moderations.goto_moderation"))
      end
    end
  end
end
