# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    module Directory
      class ApplicationController < Decidim::ApplicationController
        helper Decidim::Meetings::Directory::ApplicationHelper
      end
    end
  end
end
