# frozen_string_literal: true

module Decidim
  module Assemblies
    # Custom helpers, scoped to the participatory processes engine.
    #
    module ApplicationHelper
      include Decidim::ResourceHelper
      include PaginateHelper
    end
  end
end
