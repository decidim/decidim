# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conferences::MediaLink`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      class MediaLinkPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :string,
            link: :string,
            date: :date,
            weight: :integer
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.media_link"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.media_link.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
