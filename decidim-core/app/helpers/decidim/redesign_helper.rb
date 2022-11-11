# frozen_string_literal: true

module Decidim
  # Module to add some redesign shared helper methods.
  module RedesignHelper
    def redesigned_cell_name(name)
      redesigned_name = redesigned_layout(name)

      return name unless Object.const_defined?("#{redesigned_name}_cell".camelize)

      redesigned_name
    end
  end
end
