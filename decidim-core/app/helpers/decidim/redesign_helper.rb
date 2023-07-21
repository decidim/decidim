# frozen_string_literal: true

module Decidim
  # Module to add some redesign shared helper methods.
  module RedesignHelper
    # REDESIGN_PENDING: When redesign enabled for all the controllers this
    # method will be unnecessary and the dialog-open key should be used
    # directly instead of calling this
    def modal_open_key
      redesign_enabled? ? "dialog-open" : "open"
    end

    def modal_remote_key
      redesign_enabled? ? "dialog-remote-url" : "open-url"
    end

    def data_modal_open_key
      "data-#{modal_open_key}"
    end

    def data_modal_remote_key
      "data-#{modal_remote_key}"
    end
  end
end
