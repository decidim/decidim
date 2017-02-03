# frozen_string_literal: true
module Decidim
  module Budgets
    # Custom helpers, scoped to the budgets engine.
    #
    module ApplicationHelper
      include PaginateHelper
      include Decidim::Comments::CommentsHelper
      include ProjectsHelper
    end
  end
end
