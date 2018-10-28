# frozen_string_literal: true

module Decidim
  # A ResourcePermission allows to override component permissions for an specific resource.
  class ResourcePermission < ApplicationRecord
    belongs_to :resource, polymorphic: true
  end
end
