# frozen_string_literal: true

module Decidim
  module Admin
    # Custom ApplicationRecord scoped to the Admin panel.
    #
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
