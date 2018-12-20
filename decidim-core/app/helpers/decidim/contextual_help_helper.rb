# frozen_string_literal: true

module Decidim
  # Helper to print layout elements for the different help elements available on the pages.
  module ContextualHelpHelper
    def floating_help(id, &block)
      render partial: "decidim/shared/floating_help", locals: { content: capture(&block), id: id }
    end
  end
end
