# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::Basecontroller`, which
    # override its layout and provide all kinds of useful methods.
    class ApplicationController < Decidim::Components::BaseController
      helper Decidim::CollaborativeTexts::ApplicationHelper
    end
  end
end
