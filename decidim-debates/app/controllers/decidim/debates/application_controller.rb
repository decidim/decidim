# frozen_string_literal: true

module Decidim
  module Debates
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      redesign_participatory_space_layout skip_authorize_participatory_space: true
    end
  end
end
