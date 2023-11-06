# frozen_string_literal: true

module Decidim
  module DummyResources
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
