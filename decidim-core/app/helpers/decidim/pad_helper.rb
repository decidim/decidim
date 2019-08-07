# frozen_string_literal: true

module Decidim
  # A Helper to render an Etherpad iframe.
  module PadHelper
    # Renders an iframe with the pad of a model that includes the
    # Paddable concern.
    #
    # paddable - The model to render the pad from.
    #
    # Returns nothing.
    def pad_iframe_for(paddable)
      cell "decidim/pad_iframe", paddable
    end
  end
end
