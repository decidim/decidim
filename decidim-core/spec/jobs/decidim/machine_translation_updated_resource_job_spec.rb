# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdatedResourceJob do
    let(:dummy_resource) { create :dummy_resource }

    context "when the translatable field changes" do

      it "creates jobs for combination of each field and locale" do
        updated_title = Decidim::Faker::Localized.name
        dummy_resource.update(title: updated_title)
        expect(Decidim::MachineTranslationUpdatedResourceJob).to have_been_enqueued.on_queue("default").with(dummy_resource, array_including("title"), "en")
      end

      it "enqueues the updated fields job" do
        Decidim::MachineTranslationUpdatedResourceJob.perform_now(dummy_resource, ["title"], "en")
        expect(Decidim::MachineTranslationUpdateFieldsJob).to have_been_enqueued.on_queue("default").exactly(2).times
      end
    end
  end
end
