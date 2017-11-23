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
      end.new
    end

    describe "#filter_form_for" do
      before do
        allow(helper).to receive(:url_for)
        allow(helper).to receive(:javascript_include_tag)
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
          .with(filter, { builder: FilterFormBuilder, url: helper.url_for, as: :filter, method: :get, remote: true, html: { id: nil } }, any_args)

        helper.filter_form_for(filter) do
        end
      end
    end
  end
end
