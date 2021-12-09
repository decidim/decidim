# frozen_string_literal: true

module Decidim
  class ReminderRegistry
    def register(reminder_name)
      reminder_name = reminder_name.to_s
      if reminder_exists?(reminder_name)
        raise(
          ReminderAlreadyRegistered,
          "There's a reminder already registered with the name `:#{reminder_name}`, must be unique"
        )
      end

      reminder_manifest = ::Decidim::ReminderManifest.new(reminder_name: reminder_name)
      yield(reminder_manifest)
      reminder_manifest.validate!

      reminder_manifests << reminder_manifest
    end

    def for(reminder_name, list = nil)
      list ||= all
      list.find { |manifest| manifest.reminder_name == reminder_name.to_s }
    end

    def all
      reminder_manifests
    end

    class ReminderAlreadyRegistered < StandardError; end

    private

    def reminder_exists?(reminder_name)
      self.for(reminder_name).present?
    end

    def reminder_manifests
      @reminder_manifests ||= []
    end
  end
end
