# frozen_string_literal: true

module Decidim
  module MarkupHelper
    def element_id(prefix)
      "#{prefix}_#{SecureRandom.uuid}"
    end
  end
end
