# frozen_string_literal: true

module Decidim
  # This command updates the user's interests.
  class UpdateUserInterests < Decidim::Command
    delegate :current_user, to: :form
    # Updates a user's interests.
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_interests
      current_user.save!

      broadcast(:ok)
    end

    private

    attr_reader :form

    def update_interests
      current_user.extended_data ||= {}
      current_user.extended_data["interested_scopes"] = selected_scopes_ids
    end

    def selected_scopes_ids
      @form.scopes.map do |scope|
        next unless scope.checked?

        scope.id.to_i
      end.compact
    end
  end
end
