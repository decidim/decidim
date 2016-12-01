# frozen_string_literal: true
module Decidim
  module Comments
    class Comment < ApplicationRecord
      belongs_to :author, class_name: Decidim::User
      belongs_to :commentable, polymorphic: true
      
      validates :body, presence: true
    end
  end
end