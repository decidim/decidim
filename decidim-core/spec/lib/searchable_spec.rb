# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Searchable do
    subject { resource }

    let(:resource) do
      Decidim::DummyResources::DummyResource.new
    end

    after do
      Decidim::Searchable.searchable_resources.delete(subject.class.name)
    end

    describe "#searchable_fields" do
      context "when searchable_fields are correctly setted" do
        before do
          subject.class.include Searchable
          subject.class.searchable_fields({})
        end

        it "correctly resolves untranslatable fields into available_locales" do
          expect(subject.class.search_resource_fields_mapper).to be_a(Decidim::SearchResourceFieldsMapper)
        end
      end
    end
  end
end
