# frozen_string_literal: true

module Decidim
  # REDESIGN_PENDING: deprecated cell
  class FingerprintCell < Decidim::ViewModel
    include ActionView::RecordIdentifier
    include Decidim::SanitizeHelper
    include Decidim::ResourceHelper

    def show
      render
    end

    private

    def modal_name
      dom_id(model, :fingerprint_dialog)
    end
  end
end
