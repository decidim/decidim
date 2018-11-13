# frozen_string_literal: true

module Decidim
  class HelpElement < ApplicationRecord
    belongs_to :organization, class_name: "Decidim::Organization"
    validates :organization, presence: true
    validates :content, presence: true
  end
end
