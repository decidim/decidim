# frozen_string_literal: true

module Decidim
  module Headers
    # Since we are moving the sessions in the database, we are using this particular snippet to make sure the sessions
    # are updated on every request from user, so that we allow the server to know if a session is active or not.
    module SessionUpdater
      extend ActiveSupport::Concern

      included do
        before_action :touch_session
      end

      private

      def touch_session
        session[:last_seen_at] = Time.current
      end
    end
  end
end
