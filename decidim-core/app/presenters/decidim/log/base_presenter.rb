# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present a resource for any activity log.
    # It is supposed to be a base class for all other log renderers, as it defines
    # some helpful methods that later presenters can use.
    #
    # Most presenters that inherit from this class will only need to overwrite
    # the `action_string` method, which defines what I18n key will be used for
    # each action. Other methods that might be interesting to overwrite are those
    # named `present_*`. Check the source code and the method docs to see how they
    # work.
    #
    # See `Decidim::ActionLog#render_log` for more info on the log types and
    # presenters.
    #
    # Usage should be automatic and you shouldn't need to call this class
    # directly, but here's an example:
    #
    #    action_log = Decidim::ActionLog.last
    #    view_helpers # => this comes from the views
    #    BasePresenter.new(action_log, view_helpers).present
    class BasePresenter
      # Public: Initializes the presenter.
      #
      # action_log - An instance of Decidim::ActionLog
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      def initialize(action_log, view_helpers)
        @action_log = action_log
        @view_helpers = view_helpers
      end

      # Public: Renders the given `action_log`.
      #
      # action_log - An instance of Decidim::ActionLog.last
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      #
      # Returns an HTML-safe String.
      def present
        present_content
      end

      private

      attr_reader :action_log, :view_helpers
      alias h view_helpers

      delegate :action, to: :action_log

      # Private: Presents the given space.
      #
      # Returns an HTML-safe String.
      def present_space
        space_presenter.present
      end

      # Private: Caches the object that will be responsible of presenting the space
      # where the action is performed.
      #
      # Returns an object that responds to `present`.
      def space_presenter
        @space_presenter ||= Decidim::Log::SpacePresenter.new(
                               action_log.participatory_space,
                               h,
                               action_log.extra["participatory_space"]
                             )
      end

      # Private: Presents the given resource.
      #
      # Returns an HTML-safe String.
      def present_resource
        resource_presenter.present
      end

      # Private: Caches the object that will be responsible of presenting the resource
      # affected by the given action.
      #
      # Returns an object that responds to `present`.
      def resource_presenter
        @resource_presenter ||= Decidim::Log::ResourcePresenter.new(action_log.resource, h, action_log.extra["resource"])
      end

      # Private: Presents the given user.
      #
      # Returns an HTML-safe String.
      def present_user
        user_presenter.present
      end

      # Private: Caches the object that will be responsible of presenting the user
      # that performed the given action.
      #
      # Returns an object that responds to `present`.
      def user_presenter
        @user_presenter ||= Decidim::Log::UserPresenter.new(action_log.user, h, action_log.extra["user"])
      end

      # Private: Presents the date the action was performed.
      #
      # Returns an HTML-safe String.
      def present_log_date
        h.content_tag(:div, class: "logs__log__date") do
          h.localize(action_log.created_at, format: :decidim_short)
        end
      end

      # Private presents the explanation of the action. It will
      # hold the author name, the action type, the resource affected
      # and the participatory space the resource belongs to.
      #
      # Returns an HTML-safe String.
      def present_explanation
        h.content_tag(:div, class: "logs__log__explanation") do
          I18n.t(
            action_string,
            i18n_params
          ).html_safe
        end
      end

      # Private: Presents the log content with a default form.
      # It holds the date of the action and the explanation.
      #
      # Returns an HTML-safe String.
      def present_content
        h.content_tag(:li, class: "logs__log") do
          h.content_tag(:div, class: "logs__log__content") do
            present_log_date + present_explanation
          end
        end
      end

      # Private: Finds the name of the I18n key that will be used for the
      # current log action.
      #
      # Returns a String.
      def action_string
        case action.to_s
        when "create"
          "decidim.log.base_presenter.create"
        when "update"
          "decidim.log.base_presenter.update"
        else
          "decidim.log.base_presenter.unknown_action"
        end
      end

      # Private: The params to be sent to the i18n string.
      #
      # Returns a Hash.
      def i18n_params
        {
          user_name: present_user,
          resource_name: present_resource,
          space_name: present_space
        }
      end
    end
  end
end
