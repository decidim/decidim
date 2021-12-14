# frozen_string_literal: true

module Decidim
  # This class acts as a registry for reminders. Each reminder needs a name,
  # reminder times and a manager class, that will be used for generating reminders.
  # Reminder times could be used to define intervals between reminders, so that user
  # isn't reminded too often.
  #
  # In order to register a reminder, you can follow this example:
  #
  #     Decidim.reminders_registry.register(:orders) do |reminder_registry|
  #       reminder_registry.manager_class = "Decidim::Budgets::VoteReminderGenerator"
  #
  #       reminder_registry.settings do |settings|
  #         settings.attribute :reminder_times, type: :array, default: [2.hours, 1.week, 2.weeks]
  #       end
  #     end
  #
  # Reminders need to be registered in the `engine.rb` file of each module.
  class ReminderRegistry
    def register(reminder_name)
      reminder_name = reminder_name.to_s
      if reminder_exists?(reminder_name)
        raise(
          ReminderAlreadyRegistered,
          "There's a reminder already registered with the name `:#{reminder_name}`, must be unique"
        )
      end

      reminder_manifest = ::Decidim::ReminderManifest.new(name: reminder_name)
      yield(reminder_manifest)
      reminder_manifest.validate!

      reminder_manifests << reminder_manifest
    end

    def for(reminder_name, list = nil)
      list ||= all
      list.find { |manifest| manifest.name == reminder_name.to_s }
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
