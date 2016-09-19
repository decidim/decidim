# frozen_string_literal: true
module Decidim
  module System
    # Custom ApplicationRecord scoped to the system panel.
    #
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
