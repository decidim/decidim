# frozen_string_literal: true

module Decidim
  class HideChildResourcesJob < ApplicationJob
    queue_as :user_report

    def perform(resource, user_id)
      spam_user = (resource.organization.users.find_by(email: Decidim::Ai::SpamDetection.reporting_user_email) if Decidim.module_installed?(:ai))
      spam_user = resource.organization.admins.find(user_id) if spam_user.nil?

      tool = Decidim::ModerationTools.new(resource, spam_user)

      unless Decidim::Report.exists?("decidim_moderation_id" => tool.moderation.id, "decidim_user_id" => spam_user.id)
        tool.create_report!({
                              reason: "parent_hidden",
                              details: I18n.t("report_details", scope: "decidim.reports.parent_hidden")
                            })
      end

      tool.update_report_count!
      tool.hide!
    end
  end
end
