# frozen_string_literal: true

module Decidim
  module Verifications
    # A command to Destroy the Authorization of a user.
    class DestroyUserAuthorization < Rectify::Command
      def initialize(authorization)
        @authorization = authorization
      end

      def call
        return broadcast(:invalid) unless authorization

        authorization.destroy!

        broadcast(:ok, authorization)
      end

      private

      attr_reader :authorization
    end
  end
end
