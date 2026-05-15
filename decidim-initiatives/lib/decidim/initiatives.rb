# frozen_string_literal: true

require "decidim/initiatives/admin"
require "decidim/initiatives/api"
require "decidim/initiatives/engine"
require "decidim/initiatives/admin_engine"
require "decidim/initiatives/participatory_space"
require "decidim/initiatives/signatures"

module Decidim
  module Exporters
    autoload :InitiativeVotesPDF, "decidim/exporters/initiative_votes_pdf"
  end

  # Base module for the initiatives engine.
  module Initiatives
    autoload :ApplicationFormPDF, "decidim/initiatives/application_form_pdf"
    autoload :ValidatableAuthorizations, "decidim/initiatives/validatable_authorizations"

    class << self
      def config = self

      def configure
        yield self
      end
    end

    # Public setting that defines whether creation is allowed to any validated
    # user or not. Defaults to true.
    mattr_accessor :creation_enabled, default: Decidim::Env.new("INITIATIVES_CREATION_ENABLED", "auto").present?

    # Minimum number of committee members required to pass the initiative to
    # technical validation phase. Only applies to initiatives created by
    # individuals.
    mattr_accessor :minimum_committee_members, default: Decidim::Env.new("INITIATIVES_MINIMUM_COMMITTEE_MEMBERS", 2).to_i

    # Number of days available to collect supports after an initiative has been
    # published.
    mattr_accessor :default_signature_time_period_length, default: Decidim::Env.new("INITIATIVES_DEFAULT_SIGNATURE_TIME_PERIOD_LENGTH", 120).to_i

    # Components enabled for a new initiative
    mattr_accessor :default_components, default: Decidim::Env.new("INITIATIVES_DEFAULT_COMPONENTS", "pages, meetings, blogs").to_array

    # Notifies when the given percentage of supports is reached for an
    # initiative.
    mattr_accessor :first_notification_percentage, default: Decidim::Env.new("INITIATIVES_FIRST_NOTIFICATION_PERCENTAGE", 33).to_i

    # Notifies when the given percentage of supports is reached for an
    # initiative.
    mattr_accessor :second_notification_percentage, default: Decidim::Env.new("INITIATIVES_SECOND_NOTIFICATION_PERCENTAGE", 66).to_i

    # Sets the expiration time for the statistic data.
    mattr_accessor :stats_cache_expiration_time, default: Decidim::Env.new("INITIATIVES_STATS_CACHE_EXPIRATION_TIME", 5).to_i.minutes

    # Maximum amount of time in validating state.
    # After this time the initiative will be moved to
    # discarded state.
    mattr_accessor :max_time_in_validating_state, default: Decidim::Env.new("INITIATIVES_MAX_TIME_IN_VALIDATING_STATE", 60).to_i.days

    # Print functionality enabled. Allows the user to get
    # a printed version of the initiative from the administration
    # panel.
    mattr_accessor :print_enabled, default: Decidim::Env.new("INITIATIVES_PRINT_ENABLED", "auto").to_s == "true"

    # Set a service to generate a timestamp on each vote. The
    # attribute is the name of a class whose instances are
    # initialized with a string containing the data to be
    # timestamped and respond to a timestamp method
    mattr_accessor :timestamp_service, default: Decidim::Env.new("DECIDIM_TIMESTAMP_SERVICE", nil).value

    # Set a service to add a signature to pdf of signatures.
    # The attribute is the name of a class whose instances are
    # initialized with the document to be signed and respond to a
    # signed_pdf method with the signature added
    mattr_accessor :pdf_signature_service, default: Decidim::Env.new("DECIDIM_PDF_SIGNATURE_SERVICE", nil).value

    # This flag allows creating authorizations to unauthorized users.
    mattr_accessor :do_not_require_authorization, default: Decidim::Env.new("INITIATIVES_DO_NOT_REQUIRE_AUTHORIZATION").present?

    # Encryption secret to use with signatures metadata
    mattr_accessor :signature_handler_encryption_secret, default: Decidim::Env.new("INITIATIVES_SIGNATURE_HANDLER_ENCRYPTION_SECRET", "personal user metadata").to_s
  end
end
