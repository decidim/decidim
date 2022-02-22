# frozen_string_literal: true

module Decidim
  module Elections
    module AdminLog
      # This class holds the logic to present a `Decidim::Election`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ElectionPresenter.new(action_log, view_helpers).present
      class ElectionPresenter < Decidim::Log::BasePresenter
        private

        def i18n_labels_scope
          "activemodel.attributes.election"
        end

        def action_string
          case action
          when "publish", "unpublish", "create", "delete", "update",
               "setup", "start_key_ceremony", "start_vote", "end_vote", "start_tally", "report_missing_trustee", "publish_results"
            "decidim.elections.admin_log.election.#{action}"
          else
            super
          end
        end

        def i18n_params
          super.merge(trustee_info)
        end

        def trustee_info
          return {} unless action == "report_missing_trustee"

          {
            trustee_name: if trustee
                            Decidim::Log::UserPresenter.new(trustee.user, h, trustee_extra).present
                          else
                            trustee_extra["name"]
                          end
          }
        end

        def trustee
          @trustee ||= Decidim::Elections::Trustee.find(action_log.extra["extra"]["trustee_id"]) if action_log.extra["extra"]["trustee_id"]
        end

        def trustee_extra
          info = {
            "name" => trustee.name,
            "nickname" => trustee.user&.nickname
          }

          info["name"] ||= action_log.extra["extra"]["name"]
          info["nickname"] ||= action_log.extra["extra"]["nickname"]

          info
        end
      end
    end
  end
end
