# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        before_action :append_csp_directives

        private

        def append_csp_directives
          return if Decidim::Elections.bulletin_board.nil?
          return if Decidim::Elections.bulletin_board.bulletin_board_server.blank?

          content_security_policy.append_csp_directive("connect-src", Decidim::Elections.bulletin_board.bulletin_board_server)
        end
      end
    end
  end
end
