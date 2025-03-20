# frozen_string_literal: true

module Decidim
  # Helper overrides for the ActionView::Helpers::CacheHelper in order to take
  # locale into account for fragment caching.
  module CacheHelper
    # See: https://git.io/J3ouj
    def cache(name = {}, options = {}, &)
      name = Array(name) + [current_locale]

      super(name, options, &)
    end
  end
end
