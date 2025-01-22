# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

require "decidim/core/test/shared_examples/form_builder_examples"

module Decidim
  describe FilterFormBuilder do
    let(:helper) { Class.new(ActionView::Base).new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
    let(:categories) do
      create_list(:category, 3)
      Category.all
    end
    let(:scopes) { create_list(:scope, 3) }

    let(:resource) do
      Class.new do
        attr_reader :order_start_time, :scope_id, :category_id
      end.new
    end

    let(:builder) { FilterFormBuilder.new(:resource, resource, helper, {}) }

    describe "#collection_radio_buttons" do
      let(:output) do
        builder.collection_radio_buttons :order_start_time, [%w(asc asc), %w(desc desc)], :first, :last
      end
      let(:parsed) { Nokogiri::HTML(output) }

      it "renders the radio buttons outside its labels" do
        expect(parsed.css("label input")).to be_empty
      end

      context "when a help text is defined" do
        let(:field) { "input" }
        let(:help_text_text) { "This is the help text" }
        let(:output) do
          builder.collection_radio_buttons :order_start_time, [%w(asc asc), %w(desc desc)], :first, :last, help_text: help_text_text
        end

        it_behaves_like "having a help text"
      end
    end

    describe "#collection_check_boxes" do
      let(:output) do
        builder.collection_check_boxes :scope_id, scopes, :id, :name
      end
      let(:parsed) { Nokogiri::HTML(output) }

      it "renders the check boxes outside its labels" do
        expect(parsed.css("label input")).to be_empty
      end

      context "when a help text is defined" do
        let(:field) { "input" }
        let(:help_text_text) { "This is the help text" }
        let(:output) do
          builder.collection_check_boxes :scope_id, scopes, :id, :name, help_text: help_text_text
        end

        it_behaves_like "having a help text"
      end
    end
  end
end
