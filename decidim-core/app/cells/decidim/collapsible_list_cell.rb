# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of elements. Each element from the
  # `model` array will be rendered with the `:cell` cell.
  #
  # Available sizes:
  #  - `:small` => collapses after 3 elements.
  #  - `:default` => collapses after 7 elements. If not specified, this one is
  #    used.
  #
  # Example:
  #
  #    cell(
  #      "decidim/collapsible_list",
  #      my_list,
  #      cell_name: "my/cell",
  #      cell_options: { my: :options },
  #      hidden_elements_count_i18n_key: "my.custom.key",
  #      size: :small
  #    )
  class CollapsibleListCell < AuthorCell
    MIN_LENGTH_FOR_SIZE = { small: 3, default: 7 }.freeze

    private

    def list
      model
    end

    def cell_name
      options[:cell_name]
    end

    def cell_options
      options[:cell_options]
    end

    def size
      return :small if options[:size].to_s == "small"
      :default
    end

    def list_size_class
      return "small" if size == :small
      ""
    end

    def collapsible?
      list.size > MIN_LENGTH_FOR_SIZE[size]
    end

    def hidden_elements_count
      return 0 unless collapsible?
      list.size - MIN_LENGTH_FOR_SIZE[size]
    end

    def hidden_elements_count_i18n_key
      options[:hidden_elements_count_i18n_key] || "decidim.collapsible_list.hidden_elements_count"
    end

    def seed
      @seed ||= Random.rand(9999)
    end

    def actionable?
      return false if options[:has_actions] == false
      true if withdrawable? || flagable?
    end
  end
end
