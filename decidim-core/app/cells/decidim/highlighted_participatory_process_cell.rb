# frozen_string_literal: true

module Decidim
  # This cell renders the highlighted participatory process
  # with the higher weight.

  # It is used in the menu bar dropdown with a helper that returns the highlighted participatory process
  # of the current organization:
  #
  #   <%= cell("decidim/highlighted_participatory_process", menu_highlighted_participatory_process) %>
  #
  class HighlightedParticipatoryProcessCell < Decidim::ViewModel
    include Decidim::CardHelper
  end
end
