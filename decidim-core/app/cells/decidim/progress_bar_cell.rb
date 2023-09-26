# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of elements. Each element from the
  # `model` array will be rendered with the `:cell` cell.
  #
  # The `model` must be an Integer representing how many elements we have right
  # now. Can be higher than the `:total` options value.
  #
  # Available options:
  #  - `:small` => Whether the progress bar should be small or not.
  #    This will probably be set to `true` if rendered in a collection view.
  #    Defaults to `false`.
  #  - `:total` => The amount that will set the progress bar to 100%, the objective
  #    to reach.
  #  - `:units_name` => The I18n key representing the name of the elements we are
  #    counting (votes, signatures, answers...). Can have the `%{count}` format.
  #  - `:element_id` => A String representing the ID that will be given to the
  #    progress bar HTML element.
  #  - `:subtitle_text` => An I18n key representing a subtitle for the element.
  #
  # Example:
  #
  #    cell(
  #      "decidim/progress_bar",
  #      7,
  #      element_id: "my-id",
  #      units_name: "my.i18n.key",
  #      total: 10,
  #    )
  class ProgressBarCell < Decidim::ViewModel
    private

    def element_id
      options[:element_id]
    end

    def units_name
      options[:units_name]
    end

    def units_name_text
      I18n.t(units_name, count: progress)
    end

    def progress
      model
    end

    def total
      options[:total]
    end

    def percentage
      (progress.to_f / total) * 100
    end
  end
end
