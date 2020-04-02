# frozen_string_literal: true

module Decidim
  module Budgets
    module Groups
      module Admin
        # This controller is the abstract class from which all other controllers of
        # this engine inherit.
        #
        # Note that it inherits from `Decidim::Components::BaseController`, which
        # override its layout and provide all kinds of useful methods.
        class ApplicationController < Decidim::Admin::Components::BaseController
        end
      end
  end
end
