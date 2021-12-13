# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReminderRegistry do
    subject { described_class.new }

    describe "register" do
      it "registers a reminder" do
        register_reminder(:dummies)

        expect(subject.for(:dummies).try(:reminder_name)).to eq "dummies"
      end

      it "raises an error if the reminder is already registered" do
        register_reminder(:dummies)

        expect { register_reminder(:dummies) }
          .to raise_error(described_class::ReminderAlreadyRegistered)
      end
    end

    def register_reminder(name)
      subject.register(name) do |reminder_registry|
        reminder_registry.manager_class = "Decidim::DummyGenerator"
      end
    end
  end
end
