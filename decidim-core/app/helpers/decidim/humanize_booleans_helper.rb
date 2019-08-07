# frozen_string_literal: true

module Decidim
  # Helper to print booleans in a human way.
  module HumanizeBooleansHelper
    # Displays booleans in a human way (yes/no, supporting i18n). Supports
    # `nil` values as `false`.
    #
    # boolean - a Boolean that will be displayed in a human way.
    def humanize_boolean(boolean)
      value = boolean ? "true" : "false"
      I18n.t(value, scope: "booleans")
    end
  end
end
