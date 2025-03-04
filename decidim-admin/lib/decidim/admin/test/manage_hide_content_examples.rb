# frozen_string_literal: true

shared_examples "hideable resource during block" do
  include ActiveJob::TestHelper

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :confirmed, :admin, organization:) }
  let(:reportable) { create(:user, :confirmed, organization:) }
  let(:reportable_path) { decidim.profile_path(reportable.nickname) }

  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:dummy_component, participatory_space: participatory_process) }
  let(:content) { create(:dummy_resource, component:, author: reportable, published_at: Time.current) }

  before do
    switch_to_host(admin.organization.host)
    login_as admin, scope: :user
    visit reportable_path

    within ".profile__actions-secondary", match: :first do
      click_on(I18n.t("decidim.shared.flag_modal.report"))
    end
    within ".flag-user-modal" do
      find(:css, "input[name='report[block]']").set(true)
    end
    content.reload
  end

  it "chooses to hide content" do
    within ".flag-user-modal" do
      find(:css, "input[name='report[hide]']").set(true)
    end
    click_on I18n.t("decidim.shared.flag_user_modal.block")
    expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id, hide: true))
  end

  context "when finalizing hide" do
    around do |example|
      perform_enqueued_jobs do
        example.run
      end
    end

    it "chooses to hide content" do
      within ".flag-user-modal" do
        expect(page).to have_content("Report inappropriate participant")
        find(:css, "input[name='report[hide]']").set(true)
      end
      click_on I18n.t("decidim.shared.flag_user_modal.block")
      expect(page).to have_current_path(decidim_admin.new_user_block_path(user_id: reportable.id, hide: true))

      fill_in :block_user_justification, with: "This user is a spammer" * 2 # to have at least 15 chars

      click_on I18n.t("decidim.admin.block_user.new.action")

      expect(content.reload).to be_hidden

      visit decidim_admin.root_path
      expect(page).to have_content("blocked user")
    end
  end
end
