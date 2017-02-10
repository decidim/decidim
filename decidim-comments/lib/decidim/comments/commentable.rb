# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Comments
    # Shared behaviour for commentable models.
    module Commentable
      extend ActiveSupport::Concern

      included do
        include Decidim::Authorable

        has_many :comments, as: :commentable, foreign_key: "decidim_commentable_id", foreign_type: "decidim_commentable_type", class_name: "Decidim::Comments::Comment"

        def commentable?
          true
        end

        def accepts_new_comments?
          true
        end

        def comments_have_alignment?
          false
        end

        def comments_have_votes?
          false
        end

        def commentable_type
          self.class.name
        end
      end
    end
  end
end
