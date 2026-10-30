# frozen_string_literal: true

require "spec_helper"

describe "Admin flash messages after redirects" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "publishing a participatory process that is already published" do
    let(:participatory_process) { create(:participatory_process, :published, organization:) }

    it "shows the alert on the destination page" do
      post(decidim_admin_participatory_processes.participatory_process_publish_path(participatory_process))
      follow_redirect!

      expect(response.body).to include(I18n.t("create.error", scope: "decidim.admin.participatory_process_publications"))
    end
  end

  describe "unpublishing a participatory process that is not published" do
    let(:participatory_process) { create(:participatory_process, :unpublished, organization:) }

    it "shows the alert on the destination page" do
      delete(decidim_admin_participatory_processes.participatory_process_publish_path(participatory_process))
      follow_redirect!

      expect(response.body).to include(I18n.t("destroy.error", scope: "decidim.admin.participatory_process_publications"))
    end
  end

  describe "activating a step that is already active" do
    let(:step) { create(:participatory_process_step, participatory_process:, active: true) }

    it "shows the alert on the steps page" do
      post(decidim_admin_participatory_processes.participatory_process_step_activate_path(participatory_process, step))

      expect(response).to redirect_to(decidim_admin_participatory_processes.participatory_process_steps_path(participatory_process))
      follow_redirect!

      expect(response.body).to include(I18n.t("participatory_process_step_activations.create.error", scope: "decidim.admin"))
    end
  end

  describe "reordering steps without an order" do
    # The steps list reorders through an XHR request, so the alert is shown on
    # the next page the admin loads.
    it "shows the alert on the next page" do
      post(decidim_admin_participatory_processes.ordering_participatory_process_steps_path(participatory_process), xhr: true)

      expect(response).to redirect_to(decidim_admin_participatory_processes.participatory_process_path(participatory_process))

      get(decidim_admin_participatory_processes.participatory_process_steps_path(participatory_process))

      expect(response.body).to include(I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin"))
    end
  end
end
