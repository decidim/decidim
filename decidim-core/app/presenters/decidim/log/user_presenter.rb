# frozen_string_literal: true

module Decidim
  module Log
    # This class holds the logic to present the author for any activity log.
    # The data needed for this class to work should be sent by
    # `Decidim::Log::BasePresenter` or any of its children.
    #
    # In order to be able to use your own class to present a user, you will need to
    # overwrite `BasePresenter#user_presenter` to return your custom user presenter.
    # The only requirement for custom renderers is that they should respond to `present`.
    class UserPresenter
      # Public: Initializes the presenter.
      #
      # user - An instance of Decidim::User
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      # extra -  a Hash with extra data, most likely coming from the
      #   `action_log` being presented
      def initialize(user, view_helpers, extra)
        @user = user
        @view_helpers = view_helpers
        @extra = extra
      end

      # Public: Renders the resource associated to the given `action_log`.
      #
      # action_log - An instance of Decidim::ActionLog.last
      # view_helpers - An object holding the view helpers at the render time.
      #   Most probably should come automatically from the views.
      #
      # Returns an HTML-safe String.
      def present
        present_user
      end

      private

      attr_reader :user, :view_helpers, :extra
      alias h view_helpers

      # Private: Presents the given user. If the user is found in the database, it
      # links to their profile, and shows their nickname as a tooltip.
      # Otherwise it only shows the name.
      #
      # Returns an HTML-safe String.
      def present_user
        return h.content_tag(:span, present_user_name, class: "logs__log__author") if user.blank?
        return I18n.t("decidim.profile.deleted") if user.respond_to?(:deleted?) && user.deleted?

        h.link_to(
          present_user_name,
          user_path,
          class: "logs__log__author",
          title: "@#{user.nickname}"
        )
      end

      # Private: Presents the name of the user performing the action.
      #
      # Returns an HTML-safe String.
      def present_user_name
        extra["name"].html_safe
      end

      # Private: Presents the nickname of the user performing the action.
      #
      # Returns an HTML-safe String.
      def present_user_nickname
        extra["nickname"].html_safe
      end

      # Private: Calculates the path for the user. Returns the path of the
      # user profile. It is a public link.
      #
      # Returns an HTML-safe String.
      def user_path
        h.decidim.profile_path(present_user_nickname)
      end
    end
  end
end
