module Decidim
  class UpdateAccount < Rectify::Command
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      @user.attributes = {
        name: @form.name,
        email: @form.email
      }

      @user.avatar = @form.avatar if @form.avatar

      if @form.password.present?
        @user.password = @form.password
        @user.password_confirmation = @form.password_confirmation
      end

      @user.save!

      broadcast(:ok)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end
  end
end
