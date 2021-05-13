# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FiltersHelper do
    let(:filter) do
      Class.new do
        def self.model_name
          ActiveModel::Name.new(self, nil, "dummy")
        end

        include ActiveModel::Model

        attr_accessor :test_attribute
      end.new
    end

    describe "#filter_form_for" do
      before do
        allow(helper).to receive(:url_for)
        allow(helper).to receive(:javascript_pack_tag)
        allow(helper).to receive(:dummies_path)
      end

      it "wraps everything in a div with class 'filters'" do
        expect(helper)
          .to receive(:content_tag)
          .with(:div, { class: "filters" }, any_args)
          .and_call_original

        helper.filter_form_for(filter) do
        end
      end

      it "calls form_for helper with specific arguments" do
        expect(helper)
          .to receive(:form_for)
          .with(filter, { namespace: match(/^filters_[a-z0-9-]+$/), builder: FilterFormBuilder, url: helper.url_for, as: :filter, method: :get, remote: true, html: { id: nil } }, any_args)

        helper.filter_form_for(filter) do
        end
      end

      it "applies a namespace for the form field IDs to avoid duplicate IDs in the DOM" do
        namespaces = []
        original_form_for = helper.method(:form_for)
        allow(helper).to receive(:form_for) do |inner_filter, options, &block|
          namespaces << options[:namespace]
          original_form_for.call(inner_filter, options, &block)
        end

        dom = Array.new(2).collect do
          helper.filter_form_for(filter) do |form|
            form.text_field :test_attribute
          end
        end.join("")

        expect(dom).to have_tag(
          "input",
          count: 2,
          with: {
            type: "text",
            name: "filter[test_attribute]"
          }
        )
        namespaces.each do |ns|
          expect(dom).to have_tag(
            "input",
            count: 1,
            with: {
              type: "text",
              id: "#{ns}_filter_test_attribute"
            }
          )
        end
      end
    end

    describe "#filter_cache_hash" do
      let(:type) { :test }

      it "generate a unique hash" do
        old_hash = helper.filter_cache_hash(filter, type)

        expect(helper.filter_cache_hash(filter, type)).to eq(old_hash)
      end

      it "stores filter type" do
        expect(helper.filter_cache_hash(filter, type)).to start_with("decidim/proposals/filters/test")
      end

      context "when no type is provided" do
        let(:type) { nil }

        it "doesn't stores filter type" do
          expect(helper.filter_cache_hash(filter)).to start_with("decidim/proposals/filters")
        end
      end

      context "when filter is different" do
        it "generate a different hash" do
          old_hash = helper.filter_cache_hash(filter, type)
          filter.test_attribute = "dummy-filter"

          expect(helper.filter_cache_hash(filter, type)).not_to eq(old_hash)
        end
      end
    end
  end
end
