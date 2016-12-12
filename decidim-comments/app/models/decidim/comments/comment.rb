# frozen_string_literal: true
module Decidim
  module Comments
    # Some resources will be configured as commentable objects so users can
    # comment on them. The will be able to create conversations between users
    # to discuss or share their thoughts about the resource.
    class Comment < ApplicationRecord
      belongs_to :author, class_name: Decidim::User
      belongs_to :commentable, polymorphic: true
      has_many :replies, as: :commentable, class_name: Comment

      validates :author, :commentable, :body, presence: true
    end
  end
end
