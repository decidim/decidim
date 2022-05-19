# frozen_string_literal: true

module Decidim
  class UpdateAdminPassword < Decidim::Command
    # Updates a admin's password
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    attr_reader :form, :user

    def call
      return broadcast(:invalid) if form.invalid?

      user.password = form.password
      return broadcast(:invalid) unless user.valid?

      user.previous_passwords = [Decidim::User.find(user.id).encrypted_password, *user.previous_passwords].first(Decidim.admin_password_repetition_times)
      user.password_updated_at = Time.current
      user.save!
      broadcast(:ok)
    end
  end
end
