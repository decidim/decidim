# frozen_string_literal: true

module Decidim
  module AdminLog
    # This class holds the logic to present a `Decidim::Category`
    # for the `AdminLog` log.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    CategoryPresenter.new(action_log, view_helpers).present
    class CategoryPresenter < Decidim::Log::BasePresenter
      private

      def diff_fields_mapping
        {
          name: :i18n,
          description: :i18n,
          weight: :integer
        }
      end

      def action_string
        case action
        when "create", "delete", "publish", "unpublish"
          "decidim.admin_log.category.#{action}"
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
