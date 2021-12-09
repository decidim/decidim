# frozen_string_literal: true

module Decidim
  class ReminderRegistry
    def register(reminder_name)
      reminder_name = reminder_name.to_s
      if reminder_exists?
        raise(
          ReminderAlreadyRegistered,
          "There's a reminder already registered with the name `:#{reminder_name}`, must be unique"
        )
      end

      reminder_manifest = ::Decidim::ReminderManifest.new(reminder_name: reminder_name)
      reminder_manifests << reminder_manifest
    end

    class ReminderAlreadyRegistered < StandardError; end

    private

    def reminder_exists?
      false
    end

    def reminder_manifests
      @reminder_manifests ||= []
    end
  end
end
