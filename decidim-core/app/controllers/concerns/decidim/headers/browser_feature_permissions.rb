# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Headers
    # This module controls the "Permissions-Policy" header to define the
    # specific sets of browser features that the website is able to use.
    module BrowserFeaturePermissions
      extend ActiveSupport::Concern

      included do
        after_action :define_permissions_policy
      end

      private

      def define_permissions_policy
        return if response.media_type != "text/html"
        return if response.headers["Permissions-Policy"].present?

        # Allow the "unload" and "onbeforeunload" events to be used at the
        # current domain to prevent the user unintentionally changing the page
        # when they have something important to do on the page, such as an
        # unsaved form.
        #
        # This header is required because Chrome is phasing this event out due
        # to some performance issues with the back/forward cache feature of the
        # browser. However, currently there are no alternative events that would
        # allow preventing accidental page reloads, tab closing or window
        # closing.
        #
        # For further information, see:
        # https://developer.chrome.com/docs/web-platform/deprecating-unload
        # https://github.com/fergald/docs/blob/master/explainers/permissions-policy-unload.md
        #
        # Note that even Google suggests using the "beforeunload" for this
        # particular use case:
        # https://developer.chrome.com/docs/web-platform/page-lifecycle-api#events
        #
        # beforeunload
        #   Important: the beforeunload event should only be used to alert the
        #   user of unsaved changes. Once those changes are saved, the event
        #   should be removed. It should never be added unconditionally to the
        #   page, as doing so can hurt performance in some cases.
        response.headers["Permissions-Policy"] = "unload=(self)"
      end
    end
  end
end
