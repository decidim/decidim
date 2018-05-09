# frozen_string_literal: true

module Decidim
  module Meetings
    class ViewModel < Decidim::ViewModel
      include TranslatableAttributes
      include LayoutHelper
      include Decidim::Meetings::MeetingsHelper
      include Decidim::SanitizeHelper
      include Decidim::Meetings::Engine.routes.url_helpers
    end
  end
end
