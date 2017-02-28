# frozen_string_literal: true
module Decidim
  module Meetings
    # Custom helpers, scoped to the meetings engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Meetings::MapHelper
    end
  end
end
