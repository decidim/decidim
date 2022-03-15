# frozen_string_literal: true

module Decidim
  class OwnActivities < PublicActivities
    private

    def visibility
      %w(private-only public-only all)
    end
  end
end
