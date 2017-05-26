# frozen_string_literal: true

module Decidim
  # Main ActiveRecord application configuration.
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
