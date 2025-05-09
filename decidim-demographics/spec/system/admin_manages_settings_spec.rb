# frozen_string_literal: true

require "spec_helper"

describe "Admin manages demographics" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:demographic) { create(:demographic, organization:, collect_data:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "and managing settings" do
    before do
      visit decidim_admin.root_path
      click_on "Insights"
      click_on "Demographics Settings"
    end

    context "and not collecting data" do
      let(:collect_data) { false }

      it "enables data collection" do
        expect(demographic.reload.collect_data).to be_falsey

        check I18n.t("decidim.demographics.admin.settings.show.collect_data")
        click_on "Save"

        expect(page).to have_content("Demographic data successfully saved")
        expect(demographic.reload.collect_data).to be_truthy
      end
    end

    context "and already collecting data" do
      let(:collect_data) { true }

      it "disables data collection" do
        expect(demographic.reload.collect_data).to be_truthy

        uncheck I18n.t("decidim.demographics.admin.settings.show.collect_data")
        click_on "Save"

        expect(page).to have_content("Demographic data successfully saved")
        expect(demographic.reload.collect_data).to be_falsey
      end
    end
  end
end
