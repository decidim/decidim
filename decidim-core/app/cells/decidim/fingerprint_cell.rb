# frozen_string_literal: true

module Decidim
  class FingerprintCell < Decidim::ViewModel
    include ActionView::RecordIdentifier

    def show
      render
    end

    private

    def modal_name
      dom_id(model, :fingerprint_dialog)
    end
  end
end
