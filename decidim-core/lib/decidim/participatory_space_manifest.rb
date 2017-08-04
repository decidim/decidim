# frozen_string_literal: true

require "decidim/settings_manifest"

module Decidim
  # This class handles all the logic associated to configuring a participatory
  # space, the highest level object of Decidim.
  #
  # It's normally not used directly but through the API exposed through
  # `Decidim.register_participatory_space`.
  class ParticipatorySpaceManifest
    include ActiveModel::Model
    include Virtus.model

    attribute :admin_engine, Rails::Engine
    attribute :engine, Rails::Engine

    attribute :name, Symbol

    # A String with the feature's icon. The icon must be stored in the
    # engine's assets path.
    attribute :icon, String

    validates :name, presence: true

    # Public: A block that gets called when seeding for this feature takes place.
    #
    # Returns nothing.
    def seeds(&block)
      @seeds = block
    end

    # Public: Creates the seeds for this features in order to populate the database.
    #
    # Returns nothing.
    def seed!
      @seeds&.call
    end
  end
end
