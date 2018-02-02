# frozen_string_literal: true

module Decidim
  module Accountability
    module AdminLog
      # This class holds the logic to present a `Decidim::Accountability::Result`
      # for the `AdminLog` log. See `Decidim::ActionLog#render_log` for
      # more info on the log types and presenters.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ResultPresenter.new(action_log, view_helpers).present
      class ResultPresenter
        # Initializes the presenter.
        #
        # action_log - An instance of Decidim::ActionLog.last
        # view_helpers - An object holding the view helpers at the render time.
        #   Most probably should come automatically from the views.
        def initialize(action_log, view_helpers)
          @action_log = action_log
          @view_helpers = view_helpers
        end

        # Renders the resource associated to the given `action_log`.
        #
        # action_log - An instance of Decidim::ActionLog.last
        # view_helpers - An object holding the view helpers at the render time.
        #   Most probably should come automatically from the views.
        def present
          h.content_tag(:li) do
            I18n.t(
              action_string,
              i18n_params
            ).html_safe +
              " (#{h.localize(action_log.created_at, format: :decidim_short)})"
          end
        end

        private

        attr_reader :action_log, :view_helpers
        alias h view_helpers

        delegate :action, :user, :resource, :feature, :participatory_space, to: :action_log

        def present_space
          return present_space_name if participatory_space.blank?

          h.link_to(present_space_name, space_path)
        end

        def present_resource
          return present_resource_name if resource.blank?

          h.link_to(present_resource_name, resource_path)
        end

        def space_path
          Decidim::ResourceLocatorPresenter.new(participatory_space).path
        end

        def resource_path
          Decidim::ResourceLocatorPresenter.new(resource).path
        end

        def present_space_name
          action_log.extra["participatory_space"]["title"]["ca"]
        end

        def present_resource_name
          action_log.extra["resource"]["title"]["ca"]
        end

        def present_user
          return present_user_name if user.blank?
          h.link_to(present_user_name, h.decidim.profile_path(action_log.extra["user"]["nickname"]))
        end

        def present_user_name
          name = action_log.extra["user"]["name"]
          nickname = action_log.extra["user"]["nickname"]
          "#{name} @#{nickname}"
        end

        def action_string
          case action
          when "create"
            "decidim.accountability.admin_log.result.create"
          when "update"
            "decidim.accountability.admin_log.result.update"
          end
        end

        def i18n_params
          {
            user_name: present_user,
            result_name: present_resource,
            space_name: present_space
          }
        end
      end
    end
  end
end
