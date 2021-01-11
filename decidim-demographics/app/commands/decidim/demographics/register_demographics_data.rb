# frozen_string_literal: true

module Decidim
  module Demographics
    # A command with all the business logic when creating a new organization in
    # the system. It creates the organization and invites the admin to the
    # system.
    class RegisterDemographicsData < Rectify::Command
      def initialize(demographic, form)
        @demographic = demographic
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          persist_demographics
        end

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      protected

      attr_reader :form, :demographic

      def persist_demographics
        demographic.data ||= {}
        form.attributes.map do |k, v|
          demographic.data[k] = v
        end
        demographic.save!
      end
    end
  end
end
