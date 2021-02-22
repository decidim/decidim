# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module UserSessionTime
    extend ActiveSupport::Concern

    included do
      before_action :update_users_last_activity
    end

    def update_user_last_activity
      session[:last_activity] = Time.current
    end
  end
end
