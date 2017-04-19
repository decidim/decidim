# frozen_string_literal: true
module Decidim
  module WidgetUrlsHelper
    def embed_modal_for(url)
      embed_code = "#{content_tag(:script, '', src: url)}"
      render partial: "decidim/shared/embed_modal", locals: { embed_code: embed_code }
    end
  end
end
