# frozen_string_literal: true

require "spec_helper"

describe "Admin flash messages after redirects" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }

  def expect_message_after_redirect(message)
    follow_redirect!

    expect(response.body).to include(message)
  end

  before do
    host! organization.host
    login_as user, scope: :user
  end

  describe "global moderations" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:component, participatory_space:) }
    let(:reportable) { create(:dummy_resource, component:) }
    let(:moderation) { create(:moderation, reportable:, report_count: 1) }

    before { create(:report, moderation:) }

    it "shows the alert after failing to unreport a resource" do
      stub_command_broadcast(Decidim::Admin::UnreportResource, :invalid)

      put(decidim_admin.unreport_moderation_path(moderation))

      expect(response).to redirect_to(decidim_admin.moderations_path)
      expect_message_after_redirect(I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin"))
    end

    it "shows the alert after failing to hide a resource" do
      stub_command_broadcast(Decidim::Admin::HideResource, :invalid)

      put(decidim_admin.hide_moderation_path(moderation))

      expect(response).to redirect_to(decidim_admin.moderations_path)
      expect_message_after_redirect(I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin"))
    end

    it "shows the alert after a bulk action without selected moderations" do
      patch(decidim_admin.bulk_action_moderations_path, params: { bulk_action: "hide", moderation_ids: [] })

      expect(response).to redirect_to(decidim_admin.moderations_path)
      expect_message_after_redirect(I18n.t("reportable.bulk_action.hide.invalid", scope: "decidim.moderations.admin"))
    end
  end

  describe "moderated users" do
    let(:reported_user) { create(:user, :confirmed, organization:) }
    let!(:user_moderation) { create(:user_moderation, user: reported_user) }

    it "shows the alert after failing to ignore a report" do
      stub_command_broadcast(Decidim::Admin::UnreportUser, :invalid)

      put(decidim_admin.ignore_moderated_user_path(user_moderation))

      expect(response).to redirect_to(decidim_admin.moderated_users_path)
      expect_message_after_redirect(I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin"))
    end

    it "shows the alert after a bulk unreport without selected users" do
      patch(decidim_admin.bulk_unreport_moderated_users_path, params: { user_ids: [] })

      expect(response).to redirect_to(decidim_admin.moderated_users_path)
      expect_message_after_redirect(I18n.t("reportable.bulk_action.ignore.invalid", scope: "decidim.moderations.admin"))
    end

    it "shows the alert after a bulk unblock without selected users" do
      delete(decidim_admin.bulk_destroy_moderated_users_path, params: { user_ids: [] })

      expect(response).to redirect_to(decidim_admin.moderated_users_path)
      expect_message_after_redirect(I18n.t("officializations.bulk_action.unblock.invalid", scope: "decidim.admin"))
    end
  end
end
