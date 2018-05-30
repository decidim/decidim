# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Searchable do
    subject { resource }

    let(:resource) do
      dbl = double(:dummy_resource)
      allow(dbl.class).to receive_messages(has_many: 1, after_create: 1, after_update: 1)
      dbl
    end

    describe "#searchable_fields" do
      context "when searchable_fields are correctly setted" do
        before do
          subject.class.include Searchable
          subject.class.searchable_fields({})
        end

        it "correctly resolves untranslatable fields into available_locales" do
          expect(subject.class.search_rsrc_fields_mapper).to be_a(Decidim::SearchResourceFieldsMapper)
        end
      end
    end
  end
end
