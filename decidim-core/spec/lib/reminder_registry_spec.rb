# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReminderRegistry do
    subject { described_class.new }

    describe "#register" do
      before { register_reminder(:dummies) }

      it "registers a reminder" do
        expect(subject.for(:dummies).try(:name)).to eq "dummies"
      end

      it "raises an error if the reminder is already registered" do
        expect { register_reminder(:dummies) }
          .to raise_error(described_class::ReminderAlreadyRegistered)
      end
    end

    describe "#all" do
      before do
        register_reminder(:dummies)
        register_reminder(:dummies2, "Decidim::DummyGenerator2")
      end

      it "returns manifests" do
        expect(subject.all).to be_kind_of(Array)
        expect(subject.all.count).to eq(2)
      end
    end

    def register_reminder(name, generator_class_name = "Decidim::DummyGenerator")
      subject.register(name) do |reminder_registry|
        reminder_registry.generator_class_name = generator_class_name
      end
    end
  end

  class DummyGenerator < Object; end

  class DummyGenerator2 < Object; end
end
