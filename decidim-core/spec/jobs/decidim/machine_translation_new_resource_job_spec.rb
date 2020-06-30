# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationNewResourceJob do
    let(:dummy_resource) { build :dummy_resource }
    it "enqueues new resource job" do
      dummy_resource.save
      expect(Decidim::MachineTranslationNewResourceJob).to have_been_enqueued.on_queue("default").with(dummy_resource, "en")
    end
    
    it "enqueues create field job" do
      dummy_resource.save
      MachineTranslationNewResourceJob.perform_now(dummy_resource, "en")
      expect(Decidim::MachineTranslationCreateFieldsJob).to have_been_enqueued.on_queue("default").exactly(2).times
    end
  end
end