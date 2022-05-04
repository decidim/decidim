# frozen_string_literal: true

module Decidim
  # This class acts as a registry for reminders. Each reminder needs a name,
  # and a generator class, that will be used for generating the actual sendable reminders.
  # Reminder times could be used to define intervals between reminders, so that user
  # isn't reminded too often. In addition, you can register form and command classes
  # for additional features, such as order reminders can be sent manually from the admin panel.
  # Notice that if you implement admin panel functionality, you should add 118n messages too.
  #
  # In order to register a reminder, you can follow this example:
  #
  #     Decidim.reminders_registry.register(:orders) do |reminder_registry|
  #       reminder_registry.generator_class_name = "Decidim::Budgets::OrderReminderGenerator"
  #       reminder_registry.form_class_name = "Decidim::Budgets::Admin::OrderReminderForm"
  #       reminder_registry.command_class_name = "Decidim::Budgets::Admin::CreateOrderReminders"
  #
  #       reminder_registry.settings do |settings|
  #         settings.attribute :reminder_times, type: :array, default: [2.hours, 1.week, 2.weeks]
  #       end
  #
  #       reminder_registry.messages do |msg|
  #         msg.set(:title) { |count: 0| I18n.t("decidim.budgets.admin.reminders.orders.title", count: count) }
  #         msg.set(:description) { I18n.t("decidim.budgets.admin.reminders.orders.description") }
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
