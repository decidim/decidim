# frozen_string_literal: true

module Decidim
  # Use this cell to add content that can be collapsed. Use `nil` as the `model`
  # value.
  #
  # Options:
  #   open - If the collapsed content should be shown or not on page load.
  #     Defaults to `false`.
  #   label - The contents of the link that toggles the collapse. Use a cell
  #     partial for this.
  #   content - The HTML that should be collapsed. Use a cell partial for this.
  #
  # Usage:
  #   cell(
  #     "decidim/toggle",
  #     nil,
  #     label: cell("my/cell").my_view,
  #     content: cell("my/cell").another_view
  #   )
  class ToggleCell < Decidim::ViewModel
    include LayoutHelper

    private

    def open?
      @open ||= options[:open].to_s == "true"
    end

    def random_seed
      @random_seed ||= Random.rand(9999)
    end

    def toggled_content
      options[:content]
    end

    def toggled_label
      options[:label]
    end
  end
end
