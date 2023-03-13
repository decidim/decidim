# frozen_string_literal: true

module Decidim
  # Decidim command updates user's password
  class UpdatePassword < Decidim::Command
    # Updates a user's password.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) if form.invalid?

      user.password = form.password
      user.password_confirmation = form.password
      user.password_updated_at = Time.current

      if user.save
        broadcast(:ok)
      else
        broadcast(:invalid)
      end
    end

    private

    attr_reader :form, :user
  end
end
