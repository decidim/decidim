# frozen_string_literal: true

module Decidim
  module Meetings
    class ViewModel < Decidim::ViewModel
      include TranslatableAttributes
      include LayoutHelper
      include Decidim::Meetings::MeetingsHelper
      include Decidim::SanitizeHelper
    end
  end
end
