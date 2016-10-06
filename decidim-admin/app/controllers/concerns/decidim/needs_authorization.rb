# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need authorization to work.
  module NeedsAuthorization
    extend ActiveSupport::Concern

    included do
      include Pundit
      after_action :verify_authorized

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      private

      # Overwrites the `policy` method from the `pundit` gem in order to be
      # able to specify which policy class should be used in each case. This is
      # due to `pundit` failing to correctly identify the policy class when the
      # model class name is scoped and the policy class is in a different scope
      # (eg. `Decidim::ParticipatoryProcess` and
      # `Decidim::Admin::ParticipatoryProcessPolicy`). The original method does
      # not let us specify the correct class.
      #
      # Remember that, in order to make this work, you'll need to define the
      # `policy_class` method in the controller, which should only return a
      # policy class name.
      #
      # record - the record that will be evaluated against the policy class.
      def policy(record)
        policies[record] ||= policy_class.new(current_user, record)
      end

      # Needed in order to make the `policy` method work. Overwirite it in the
      # given controller and make it return a Policy class.
      def policy_class
        raise NotImplementedError, "Define this method and make it return a policy class name in order to make it work"
      end

      # Handles the case when a user visits a path that is not allowed to them.
      # Redirects the user to the root path and shows a flash message telling
      # them they are not authorized.
      def user_not_authorized
        flash[:alert] = t("actions.unauthorized", scope: "decidim.admin")
        redirect_to(request.referrer || decidim_admin.root_path)
      end
    end
  end
end
