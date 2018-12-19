# frozen_string_literal: true

module Decidim
  # This command updates the user's interests.
  class UpdateUserInterests < Rectify::Command
    # Updates a user's intersts.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_interests
      @user.save!

      broadcast(:ok)
    end

    private

    def update_interests
      @user.extended_data ||= {}
      @user.extended_data["interested_scopes"] = selected_scopes_ids
    end

    def selected_scopes_ids
      @form.scopes.select(&:checked).map(&:id)
    end
  end
end
