# frozen_string_literal: true

require "active_support/concern"
require "paranoia"

module Decidim
  # This concern contains the logic related to soft deletion (trashing).
  module SoftDeletable
    extend ActiveSupport::Concern

    included do
      acts_as_paranoid

      scope :deleted_at_desc, -> { order(deleted_at: :desc) }
    end
  end
end
