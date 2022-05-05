# frozen_string_literal: true

module Decidim
  # This class holds the configuration for a participatory space's context. A context consists of an
  # engine, a layout and a set of helpers (usually used by the layout itself).
  class ParticipatorySpaceContextManifest
    include ActiveModel::Model
    include Decidim::AttributeObject::Model

    attribute :engine, Rails::Engine, **{}
    attribute :helper
    attribute :layout
  end
end
