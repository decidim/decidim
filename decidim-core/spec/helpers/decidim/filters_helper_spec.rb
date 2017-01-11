# coding: utf-8
# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe FiltersHelper do
    let(:filter) { Class.new.new }

    describe "#filter_form_for" do
      before :each do
        allow(helper).to receive(:url_for)
      end

      it "should wrap everything in a div with class 'filters'" do
        expect(helper)
          .to receive(:content_tag)
          .with("div", "", { class: "filters" }, any_args)

        helper.filter_form_for(filter)
      end
      
      it "should call form_for helper with specific arguments" do
        expect(helper)
          .to receive(:form_for)
          .with(filter, { builder: FilterFormBuilder, url: helper.url_for, as: :filter, method: :get, remote: true }, any_args)

        helper.filter_form_for(filter)
      end
    end
  end
end
