# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TranslatableResource do
    subject { dummy_resource.class }

    let(:dummy_resource) { build :dummy_resource }

    describe "translatable_fields_list" do
      it "gets the list of defined translatable fields" do
        expect(subject.translatable_fields_list).to eq([:title])
      end
    end
  end
end
