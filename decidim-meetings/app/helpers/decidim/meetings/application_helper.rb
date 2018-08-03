# frozen_string_literal: true

module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::MapHelper
      include Decidim::Meetings::MapHelper
      include Decidim::Meetings::MeetingsHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
