# frozen_string_literal: true

require "decidim/meetings/registrations/code_generator"

module Decidim
  module Meetings
    module Registrations
      # Public: Stores an instance of Registrations::CodeGenerator
      def self.code_generator
        @code_generator ||= Decidim::Meetings::Registrations::CodeGenerator.new
      end
    end
  end
end
