# frozen_string_literal: true

module Decidim
  module Meetings
    class RegistrationTypeEnum < Decidim::Api::Types::BaseEnum
      description "The registration types for meetings"

      value "REGISTRATION_DISABLED", value: "registration_disabled", description: "Registration disabled", value_method: false
      value "ON_THIS_PLATFORM", value: "on_this_platform", description: "On this platform", value_method: false
      value "ON_DIFFERENT_PLATFORM", value: "on_different_platform", description: "On a different platform", value_method: false
    end
  end
end
