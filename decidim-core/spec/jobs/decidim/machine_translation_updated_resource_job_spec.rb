# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationUpdatedResourceJob do
    subject { dummy_resource.class }

    let(:organization) { create(:organization) }
    let(:available_locales) { organization.available_locales }
    let(:dummy_resource) { build :dummy_resource }

    context "when the address changes" do
      let(:title) { { en: "title" } }

      it "creates jobs for combination of each field and locale" do
        translatable_fields = subject.translatable_fields_list.map(&:to_s)

        translatable_fields.each do |field|
        end

        expect(Decidim::MachineTranslationUpdateFieldsJob).to have_been_enqueued.on_queue("default").at_least(translatable_fields.size * available_locales.size).times
      end
    end
  end
end
