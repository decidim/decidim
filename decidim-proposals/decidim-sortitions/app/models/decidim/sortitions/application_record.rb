# frozen_string_literal: true

module Decidim
  module Sortitions
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
