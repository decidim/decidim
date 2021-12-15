# frozen_string_literal: true

require "spec_helper"
describe "Admin manages moderated users", type: :system do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:reportable_users) { create_list(:user, 50, :confirmed, organization: organization) }

  before do
    reportable_users.each do |reportable_user|
      moderation = create(:user_moderation, user: reportable_user, report_count: 1)
      create(:user_report, moderation: moderation, user: user, reason: "spam")
    end

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.moderated_users_path
  end

  it_behaves_like "a paginated collection"
end
