# frozen_string_literal: true
module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, String

      mimic :comment

      validates :body, presence: true
    end
  end
end
