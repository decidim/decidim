# frozen_string_literal: true

require "decidim/initiatives/admin"
require "decidim/initiatives/engine"
require "decidim/initiatives/admin_engine"
require "decidim/initiatives/participatory_space"

module Decidim
  # Base module for the initiatives engine.
  module Initiatives
    include ActiveSupport::Configurable

    # Public setting that defines whether creation is allowed to any validated
    # user or not. Defaults to true.
    config_accessor :creation_enabled do
      true
    end

    # Public Setting that defines the similarity minimum value to consider two
    # initiatives similar. Defaults to 0.25.
    config_accessor :similarity_threshold do
      0.25
    end

    # Public Setting that defines how many similar initiatives will be shown.
    # Defaults to 5.
    config_accessor :similarity_limit do
      5
    end

    # Minimum number of committee members required to pass the initiative to
    # technical validation phase. Only applies to initiatives created by
    # individuals.
    config_accessor :minimum_committee_members do
      2
    end

    # Number of days available to collect supports after an initiative has been
    # published.
    config_accessor :default_signature_time_period_length do
      120
    end

    # Components enabled for a new initiative
    config_accessor :default_components do
      [:pages, :meetings]
    end

    # Notifies when the given percentage of supports is reached for an
    # initiative.
    config_accessor :first_notification_percentage do
      33
    end

    # Notifies when the given percentage of supports is reached for an
    # initiative.
    config_accessor :second_notification_percentage do
      66
    end

    # Sets the expiration time for the statistic data.
    config_accessor :stats_cache_expiration_time do
      5.minutes
    end

    # Maximum amount of time in validating state.
    # After this time the initiative will be moved to
    # discarded state.
    config_accessor :max_time_in_validating_state do
      60.days
    end

    # Print functionality enabled. Allows the user to get
    # a printed version of the initiative from the administration
    # panel.
    config_accessor :print_enabled do
      true
    end

    # This flag says when mixed and face-to-face voting methods
    # are allowed. If set to false, only online voting will be
    # allowed
    config_accessor :face_to_face_voting_allowed do
      true
    end

    # This flag says when mixed and online voting methods
    # are allowed. If set to false, only offline voting will be
    # allowed
    config_accessor :online_voting_allowed do
      true
    end

    # This flag allows creating authorizations to unauthorized users.
    config_accessor :do_not_require_authorization do
      false
    end
  end
end
