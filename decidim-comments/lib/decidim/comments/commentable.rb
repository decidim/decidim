# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Shared behaviour for commentable models.
    module Commentable
      extend ActiveSupport::Concern

      included do
        include Decidim::Authorable

        def is_commentable?
          false # TODO: true
        end

        def comments_have_alignment?
          false
        end

        def comments_have_votes?
          false
        end
      end
    end
  end
end
