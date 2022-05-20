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

      if user.save
        broadcast(:ok)
      else
        broadcast(:invalid)
      end
    end
  end
end
