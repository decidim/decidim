# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatableResource do
    let(:dummy_resource) { build :dummy_resource }

    describe "translatable_fields_list" do
      it "gets the list of defined translatable fields" do
        expect(dummy_resource.class.translatable_fields_list).to eq([:title])
      end
    end

    describe "when new resource is created" do
      let(:dummy_resource) { create :dummy_resource }
      let(:new_resource) { create :dummy_resource}
      it " enqueues machine translation new resource job" do
        expect(Decidim::MachineTranslationNewResourceJob).to have_been_enqueued.on_queue("default")
      end
    end

    context "when new resource is updated" do
      before do
        updated_title = Decidim::Faker::Localized.name
        dummy_resource.update(title: updated_title)      
      end
      it "enqueues machine translation update resource job" do
        expect(Decidim::MachineTranslationUpdatedResourceJob).to have_been_enqueued.on_queue("default")
      end
    end


  end
end
