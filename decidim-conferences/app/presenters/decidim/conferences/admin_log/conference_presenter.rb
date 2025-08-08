# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conference`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    `ConferencePresenter`.new(action_log, view_helpers).present
      class ConferencePresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            description: :i18n,
            promoted: :boolean,
            published_at: :date,
            reference: :string,
            short_description: :i18n,
            objectives: :i18n,
            show_statistics: :boolean,
            slug: :default,
            subtitle: :i18n,
            title: :i18n,
            start_date: :date,
            end_date: :date,
            sign_date: :date,
            signature_name: :string
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conference"
        end

        def action_string
          case action
          when "create", "publish", "unpublish", "update", "update_diploma", "soft_delete", "restore"
            "decidim.admin_log.conference.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(unpublish)
        end
      end
    end
  end
end
