# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdatedResourceJob do
    let(:dummy_resource) { build :dummy_resource }

    context "when the address changes" do
      before do
        updated_title = Decidim::Faker::Localized.name
        dummy_resource.update(title: updated_title)      
      end

      it "creates jobs for combination of each field and locale" do
        expect(Decidim::MachineTranslationUpdateFieldsJob).to have_been_enqueued.on_queue("default")
      end
    end
  end
end
