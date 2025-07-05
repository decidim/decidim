# frozen_string_literal: true

require "spec_helper"

describe "Admin chooses user block templates when blocking user" do
  let(:organization) { create(:organization, default_locale: :en) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::ModeratedUsersController }

  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:moderation) { create(:user_moderation, user:, report_count: 1) }
  let!(:user_report) { create(:user_report, moderation:, user: admin, reason: "spam") }

  let!(:template) { create(:template, :user_block, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when on reported users path" do
    before do
      visit decidim_admin.moderated_users_path
      within "tr", text: user.name do
        find("button[data-component='dropdown']").click
        click_on "Block User"
      end
    end

    after do
      expect_no_js_errors
    end

    it "blocks the user" do
      select template.name["en"], from: :block_template_chooser, wait: 5
      expect(page).to have_field(:block_user_justification, with: translated(template.description))

      within("[data-content]") do
        find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("successfully")

      expect(user.reload).to be_blocked
      expect(user.reload.blocking.justification).to eq(template.description["en"])
    end
  end
end
