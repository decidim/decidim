# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationNewResourceJob do
    subject { dummy_resource.class }
    let(:organization) { create(:organization) } 
    let(:available_locales) { organization.available_locales }
    let(:dummy_resource) { build :dummy_resource }

    it "creates jobs for each translatable field and available locale" do
      translatable_fields = subject.translatable_fields_list.map(&:to_s)
      expect(Decidim::MachineTranslationCreateFieldsJob).to have_been_enqueued.on_queue("default").at_least(translatable_fields.size * available_locales.size).times
    end    
  end
end