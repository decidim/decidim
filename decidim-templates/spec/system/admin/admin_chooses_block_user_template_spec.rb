# frozen_string_literal: true


require "spec_helper"

describe "Admin chooses user block templates when blocking user", type: :system do
  let(:organization) { create(:organization, default_locale: :en) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::ModeratedUsersController }

  let!(:first_user) { create(:user, :confirmed, organization:) }
  let!(:first_moderation) { create(:user_moderation, user: first_user, report_count: 1) }
  let!(:first_user_report) { create(:user_report, moderation: first_moderation, user: admin, reason: "spam") }

  let!(:template) { create(:template, :user_block, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when on reported users path" do

    before do
      visit decidim_admin.moderated_users_path
      click_link "Block User"
    end

    after do
      expect_no_js_errors
    end

    it "blocks the user" do
      select template.name["en"], from: :block_template_chooser, wait: 5
      wait_for_ajax

      find("*[type=submit]").click
      expect(page).to have_admin_callout("successfully")

      expect(first_user.reload.blocked?).to be_truthy
      expect(first_user.reload.blocking.justification).to eq(template.description["en"])
    end
  end
end
