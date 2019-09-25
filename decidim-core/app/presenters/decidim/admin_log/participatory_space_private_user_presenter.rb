# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::ParticipatorySpacePrivateUserPresenter`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    ParticipatorySpacePrivateUserPresenter.new(action_log, view_helpers).present
    class ParticipatorySpacePrivateUserPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :string,
          email: :string
        }
      end

      def action_string
        case action
        when "create", "create_via_csv", "delete"
          "decidim.admin_log.participatory_space_private_user.#{action}"
        else
          super
        end
      end

      def i18n_labels_scope
        "activemodel.attributes.participatory_space_private_user"
      end
    end
  end
end
