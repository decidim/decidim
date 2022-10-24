# frozen_string_literal: true

module Decidim
  # This command updates the user's account.
  class UpdateAccount < Decidim::Command
    # Updates a user's account.
    #
    # user - The user to be updated.
    # form - The form with the data.
    def initialize(user, form)
      @user = user
      @form = form
    end

    def call
      return broadcast(:invalid) unless @form.valid?

      update_personal_data
      update_avatar
      update_password

      if @user.valid?
        @user.save!
        notify_followers
        broadcast(:ok, @user.unconfirmed_email.present?)
      else
        [:avatar, :password, :password_confirmation].each do |key|
          @form.errors.add key, @user.errors[key] if @user.errors.has_key? key
        end
        broadcast(:invalid)
      end
    end

    private

    def update_personal_data
      @user.locale = @form.locale
      @user.name = @form.name
      @user.nickname = @form.nickname
      @user.email = @form.email
      @user.personal_url = @form.personal_url
      @user.about = @form.about
    end

    def update_avatar
      if @form.avatar.present?
        @user.avatar.attach(@form.avatar)
      elsif @form.remove_avatar
        @user.avatar = nil
      end
    end

    def update_password
      return if @form.password.blank?

      @user.password = @form.password
      @user.password_confirmation = @form.password_confirmation
    end

    def notify_followers
      return if (@user.previous_changes.keys & %w(about personal_url)).empty?

      Decidim::EventsManager.publish(
        event: "decidim.events.users.profile_updated",
        event_class: Decidim::ProfileUpdatedEvent,
        resource: @user,
        followers: @user.followers
      )
    end
  end
end
