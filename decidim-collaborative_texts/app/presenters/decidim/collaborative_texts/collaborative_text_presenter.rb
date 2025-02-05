# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    #
    # Decorator for collaborative texts
    #
    class CollaborativeTextPresenter < Decidim::ResourcePresenter
      include Decidim::TranslationsHelper
      include Decidim::ResourceHelper
      include Decidim::SanitizeHelper
      include ActionView::Helpers::DateHelper
    end
  end
end
