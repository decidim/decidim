# frozen_string_literal: true
module Decidim
  module Proposals
    # Custom helpers, scoped to the pages engine.
    #
    module ApplicationHelper
      include Decidim::Comments::CommentsHelper
    end
  end
end
