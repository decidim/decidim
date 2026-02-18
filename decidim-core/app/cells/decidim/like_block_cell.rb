# frozen_string_literal: true

module Decidim
  class LikeBlockCell < Decidim::ViewModel
    def show
      return unless likes_enabled?

      render :show
    end

    alias resource model
  end
end
