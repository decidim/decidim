# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::Conferences::Partner`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    PartnerPresenter.new(action_log, view_helpers).present
      class PartnerPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            name: :string,
            partner_type: :string,
            link: :string,
            weight: :integer,
            log: :string
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conferences.partner"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.conferences.partner.#{action}"
          else
            super
          end
        end

        def has_diff?
          action == "delete" || super
        end
      end
    end
  end
end
