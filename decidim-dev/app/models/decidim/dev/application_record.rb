# frozen_string_literal: true

module Decidim
  module Dev
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
