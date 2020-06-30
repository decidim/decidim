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

    describe "when resource is created" do
      it "enqueues the new resource job" do
        dummy_resource.save
        expect(Decidim::MachineTranslationCreateResourceJob).to have_been_enqueued.on_queue("default").with(dummy_resource, current_locale)
      end
    end

    describe "when resource is updated" do
      it "enqueues the update resource job" do
        updated_title = Decidim::Faker::Localized.name
        dummy_resource.update(title: updated_title)
        expect(Decidim::MachineTranslationUpdatedResourceJob).to have_been_enqueued.on_queue("default").with(
          dummy_resource,
          dummy_resource.translatable_previous_changes,
          current_locale
        )
      end
    end
  end
end
