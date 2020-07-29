# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module provides capability for storing conditional snippets during the
  # page view that need to be displayed in different part of the view than where
  # they are registered at.
  module NeedsSnippets
    extend ActiveSupport::Concern

    included do
      helper_method :snippets
    end

    def snippets
      @snippets ||= Decidim::Snippets.new
    end
  end
end
