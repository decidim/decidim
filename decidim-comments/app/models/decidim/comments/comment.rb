# frozen_string_literal: true
module Decidim
  module Comments
    class Comment < ApplicationRecord
      belongs_to :author, class_name: Decidim::User
      validates :body, presence: true
    end
  end
end