# frozen_string_literal: true

module Decidim
  # A ParticipatorySpace resource holds logic related to that space. It's mostly
  # used to handle whether that space should be active and published. Comparing
  # it to the `Component` class, multiple components of the same type can exist
  # per space and per organization, while for `ParticipatorySpace` there can
  # only be one of each kind per organization. This causes all elements of a
  # component to be related to that component (eg all `Proposals` belong to
  # their `component`), while for spaces this is not necessary.
  class ParticipatorySpace < ApplicationRecord
    include Publicable
    include Activable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    validates :published_at, absence: true, if: proc { |space| !space.active? }
  end
end
