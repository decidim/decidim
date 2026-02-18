# frozen_string_literal: true

module Decidim
  # This command updates the user's account.
  class UpdateAccount < Decidim::Command
    delegate :current_user, to: :form

    # Updates a user's account.
    #
    # form - The form with the data.
    def initialize(form)
      @form = form
    end

    def call
      return broadcast(:invalid, @form.password) unless @form.valid?

      update_personal_data
      update_avatar
      update_password

      if current_user.valid?
        with_events do
          changes = current_user.changed
          current_user.save!
          send_update_summary!(changes)
        end
        notify_followers
        broadcast(:ok, current_user.unconfirmed_email.present?)
      else
        [:avatar, :password].each do |key|
          @form.errors.add key, current_user.errors[key] if current_user.errors.has_key? key
        end
        broadcast(:invalid, @form.password)
      end
    end

    protected

    def event_arguments
      { resource: current_user }
    end

    private

    attr_reader :form

    def update_personal_data
      current_user.locale = @form.locale
      current_user.name = @form.name
      current_user.nickname = @form.nickname
      current_user.email = @form.email
      current_user.personal_url = @form.personal_url
      current_user.about = @form.about
    end

    def update_avatar
      if @form.avatar.present?
        current_user.avatar.attach(@form.avatar.signed_id)
      elsif @form.remove_avatar
        current_user.avatar = nil
      end
    end

    def update_password
      return if @form.password.blank?

      current_user.password = @form.password
      current_user.password_updated_at = Time.current
    end

    def notify_followers
      return unless current_user.previous_changes.keys.intersect?(%w(about personal_url))

      Decidim::EventsManager.publish(
        event: "decidim.events.users.profile_updated",
        event_class: Decidim::ProfileUpdatedEvent,
        resource: current_user,
        followers: current_user.followers
      )
    end

    def send_update_summary!(changes)
      return if changes.empty?

      updates = changes.map do |attr|
        next unless attr_set.include?(attr)

        I18n.t("activemodel.attributes.user.#{attr}")
      end
      UserUpdateMailer.notify(current_user, updates).deliver_later
    end

    def attr_set
      @attr_set ||= %w(name nickname email about personal_url encrypted_password locale)
    end
  end
end
