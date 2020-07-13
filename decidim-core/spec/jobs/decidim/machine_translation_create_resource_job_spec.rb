# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MachineTranslationCreateResourceJob do
    let(:dummy_resource) { build :dummy_resource }

    it "enqueues create field job" do
      dummy_resource.save
      MachineTranslationCreateResourceJob.perform_now(dummy_resource, "en")
      expect(Decidim::MachineTranslationCreateFieldsJob)
        .to have_been_enqueued
        .on_queue("default")
        .exactly(2)
        .times
        .with(
          dummy_resource,
          "title",
          dummy_resource.title,
          kind_of(String),
          "en"
        )
    end
  end
end
