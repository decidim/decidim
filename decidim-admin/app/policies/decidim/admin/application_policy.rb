# frozen_string_literal: true
module Decidim
  module Admin
    # Main application policy so we don't ahve to repeat the initialization
    # code in each Policy. To be used with Pundit.
    class ApplicationPolicy
      attr_reader :user, :record

      # Initializes a Policy.
      #
      # user - The User that we want to authorize.
      # record - The record on which to perform the authorizations.
      #
      def initialize(user, record)
        @user = user
        @record = record
      end
    end
  end
end
