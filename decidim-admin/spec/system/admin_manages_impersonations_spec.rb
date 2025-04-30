# frozen_string_literal: true

require "spec_helper"

describe "Admin manages impersonations" do
  let(:user) { create(:user, :admin, :confirmed, :admin_terms_accepted, organization:) }

  def navigate_to_impersonations_page
    visit decidim_admin.root_path
    click_on "Participants"
    within_admin_sidebar_menu do
      click_on "Impersonations"
    end
  end

  shared_examples_for "prevent undesired access" do
    let(:impersonatable_user) { create(:user, managed: true, organization: user.organization) }
    let(:impersonatable_user_id) { impersonatable_user.id }

    before do
      switch_to_host(organization.host)
      login_as test_user, scope: :user
    end

    context "when accessing impersonation logs" do
      it "restrict access on logs page" do
        impersonatable_user.reload

        visit decidim_admin.impersonatable_user_impersonation_logs_path(impersonatable_user_id:)

        expect(page).to have_content("You are not authorized to perform this action.")
      end

      it "restrict access on conflicts page" do
        visit decidim_admin.conflicts_path

        expect(page).to have_content("You are not authorized to perform this action.")
      end

      it "restrict access to conflict page" do
        conflict = create(:conflict, managed_user: impersonatable_user)
        visit decidim_admin.edit_conflict_path(conflict)

        expect(page).to have_content("You are not authorized to perform this action.")
      end
    end
  end

  context "when access is restricted" do
    let(:organization) { create(:organization) }

    context "when logged in as process_collaborator" do
      let(:process) { create(:participatory_process, organization:) }
      let(:test_user) { create(:process_collaborator, :confirmed, :admin_terms_accepted, participatory_process: process) }

      it_behaves_like "prevent undesired access"
    end

    context "when logged in as process_evaluator" do
      let(:process) { create(:participatory_process, organization:) }
      let(:test_user) { create(:process_evaluator, :confirmed, :admin_terms_accepted, participatory_process: process) }

      it_behaves_like "prevent undesired access"
    end

    context "when logged in as process_moderator" do
      let(:process) { create(:participatory_process, organization:) }
      let(:test_user) { create(:process_moderator, :confirmed, :admin_terms_accepted, participatory_process: process) }

      it_behaves_like "prevent undesired access"
    end
  end

  it_behaves_like "manage impersonations examples"
end
