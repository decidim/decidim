# frozen_string_literal: true
module Decidim
  module Comments
    # A form object used to create comments from the graphql api.
    #
    class CommentForm < Form
      attribute :body, String

      mimic :comment

      validates :author, :commentable, :body, presence: true

      attr_reader :author, :commentable

      def initialize(attributes = {})
        @author = attributes.delete(:author)
        @commentable = attributes.delete(:commentable)
        super
      end
    end
  end
end
