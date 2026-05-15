# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/admin_participatory_space_access_examples"

describe "AdminAccess" do
  let!(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:, title: { en: "My space" }) }
  let(:other_participatory_process) { create(:participatory_process, organization:) }

  before do
    switch_to_host(organization.host)
  end

  context "when the user is a visitor" do
    it "shows the unauthenticated message" do
      # Prevent flaky spec, where sometimes the language is not changed before the visit
      sleep 2
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)

      expect(page).to have_content "You need to log in or create an account before continuing."
    end
  end

  context "when the user is a normal user" do
    let(:user) { create(:user, :confirmed, organization:) }
    let(:unauthorized_path) { "/" }

    before do
      login_as user, scope: :user
    end

    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process) }
    end

    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_id_documents.root_path }
    end

    it_behaves_like "a 404 page" do
      let(:target_path) { decidim_admin_templates.questionnaire_templates_path }
    end
  end

  context "when the user is a process admin" do
    let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

    before do
      login_as user, scope: :user
    end

    context "and has permission" do
      before do
        visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      end

      it_behaves_like "accessing the participatory space"
    end

    context "and does not have permission" do
      before do
        visit decidim_admin_participatory_processes.edit_participatory_process_path(other_participatory_process)
      end

      it_behaves_like "showing the unauthorized error message"
    end
  end

  context "when the user is a evaluator" do
    let(:user) { create(:process_evaluator, :confirmed, participatory_process:) }

    before do
      login_as user, scope: :user
    end

    context "and has permission" do
      before do
        visit decidim_admin_participatory_processes.components_path(participatory_process)
      end

      it_behaves_like "accessing the participatory space"
    end

    context "and does not have permission" do
      before do
        visit decidim_admin_participatory_processes.components_path(other_participatory_process)
      end

      it_behaves_like "showing the unauthorized error message"
    end
  end
end
