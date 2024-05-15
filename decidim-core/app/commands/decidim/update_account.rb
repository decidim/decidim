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
      return broadcast(:invalid, @form.password) unless @form.valid?

      update_personal_data
      update_avatar
      update_password

      if @user.valid?
        changes = @user.changed
        @user.save!
        notify_followers
        send_update_summary!(changes)
        broadcast(:ok, @user.unconfirmed_email.present?)
      else
        [:avatar, :password].each do |key|
          @form.errors.add key, @user.errors[key] if @user.errors.has_key? key
        end
        broadcast(:invalid, @form.password)
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
      @user.password_updated_at = Time.current
    end

    def notify_followers
      return unless @user.previous_changes.keys.intersect?(%w(about personal_url))

      Decidim::EventsManager.publish(
        event: "decidim.events.users.profile_updated",
        event_class: Decidim::ProfileUpdatedEvent,
        resource: @user,
        followers: @user.followers
      )
    end

    def send_update_summary!(changes)
      return if changes.empty?

      updates = changes.map do |attr|
        next unless attr_set.include?(attr)

        I18n.t("activemodel.attributes.user.#{attr}")
      end
      UserUpdateMailer.notify(@user, updates).deliver_later
    end

    def attr_set
      @attr_set ||= %w(name nickname email about personal_url encrypted_password locale)
    end
  end
end
