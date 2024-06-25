# frozen_string_literal: true

module Decidim
  # Decidim command updates user's password
  class UpdatePassword < Decidim::Command
    delegate :current_user, to: :form, prefix: :current_user

    # Updates a user's password.
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid) if form.invalid?

      current_user.password = form.password
      current_user.password_updated_at = Time.current

      if current_user.save
        broadcast(:ok)
      else
        broadcast(:invalid)
      end
    end

    private

    attr_reader :form
  end
end
