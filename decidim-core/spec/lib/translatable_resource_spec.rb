# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatableResource do
    let(:dummy_resource) { create :dummy_resource }
    let(:current_locale) { "en" }

    describe "translatable fields list" do
      it "gets the list of defined translatable fields" do
        expect(dummy_resource.class.translatable_fields_list).to eq([:title])
      end
    end

    describe "when resource has machine translations and is updated" do
      let(:new_title) { { en: "New Title", machine_translations: { ca: "nou títol" } } }
      let!(:process) { create :participatory_process, title: new_title }

      before do
        updated_title = { en: "New Title", es: "nuevo título", ca: "" }
        process.update(title: updated_title)
        clear_enqueued_jobs
      end

      it "merges the machine translations to the new object" do
        expect(process.translatable_previous_changes["title"].last).to eq("en" => "New Title", "es" => "nuevo título", "ca" => "", "machine_translations" => { "ca" => "nou títol" })
      end
    end

    describe "when resource is created or updated" do
      before do
        clear_enqueued_jobs
      end

      it "enqueues the machine translation job when resource is updated" do
        updated_title = Decidim::Faker::Localized.name
        dummy_resource.update(title: updated_title)
        expect(Decidim::MachineTranslationResourceJob).to have_been_enqueued.on_queue("default").with(
          dummy_resource,
          dummy_resource.translatable_previous_changes,
          current_locale
        )
      end

      it "enqueues the machine translation job when resource is created" do
        dummy_resource.save
        expect(Decidim::MachineTranslationResourceJob).to have_been_enqueued.on_queue("default").with(
          dummy_resource,
          dummy_resource.translatable_previous_changes,
          current_locale
        )
      end

      context "when there is no machine translation service" do
        before do
          @original_translator = Decidim.config.machine_translation_service
          Decidim.config.machine_translation_service = nil
        end

        after do
          Decidim.config.machine_translation_service = @original_translator # rubocop:disable RSpec/InstanceVariable
        end

        it "doesn't enqueue a job when resource is updated" do
          updated_title = Decidim::Faker::Localized.name
          dummy_resource.update(title: updated_title)
          expect(Decidim::MachineTranslationResourceJob).not_to have_been_enqueued.on_queue("default")
        end

        it "doesn't enqueue a job when resource is created" do
          dummy_resource.save
          expect(Decidim::MachineTranslationResourceJob).not_to have_been_enqueued.on_queue("default")
        end
      end
    end
  end
end
