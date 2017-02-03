# frozen_string_literal: true
require "decidim/comments/engine"

module Decidim
  # This module contains all the logic related to the comments feature.
  # It exposes a single entry point as a rails helper method to render
  # a React component which handle all the comments render and logic.
  module Comments
    autoload :CommentsHelper, "decidim/comments/comments_helper"
  end
end
