# frozen_string_literal: true
module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Admin::ApplicationController
      helper_method :moderations

      private

      def moderations
      end
    end
  end
end
