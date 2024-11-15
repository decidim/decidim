# frozen_string_literal: true

module Decidim
  class EndorsementBlockCell < Decidim::ViewModel
    def show
      return unless endorsements_enabled?

      render :show
    end

    alias resource model
  end
end
