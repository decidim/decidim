# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of elements. Each element from the
  # `model` array will be rendered with the `:cell_name` cell.
  # `:cell_name` is optional, if not provided `card_for` helper is used.
  #
  # Available sizes:
  #  - any number between 1 and 12
  #  - default value is 3
  #
  # Example:
  #
  #    cell(
  #      "decidim/collapsible_list",
  #      my_list,
  #      cell_name: "my/cell",
  #      cell_options: { my: :options },
  #      hidden_elements_count_i18n_key: "my.custom.key",
  #      size: 4
  #    )
  class CollapsibleListCell < Decidim::ViewModel
    include Decidim::CardHelper

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
      options[:size] || 3
    end

    def list_size_class
      "show-#{size}"
    end

    def list_class
      options[:list_class]
    end

    def collapsible?
      list.size > size
    end

    def hidden_elements_count
      return 0 unless collapsible?
      list.size - size
    end

    def hidden_elements_count_i18n_key
      options[:hidden_elements_count_i18n_key] || "decidim.collapsible_list.hidden_elements_count"
    end

    def seed
      @seed ||= Random.rand(9999)
    end
  end
end
