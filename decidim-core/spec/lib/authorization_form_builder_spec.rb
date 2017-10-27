# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

module Decidim
  describe AuthorizationFormBuilder do
    let(:record) do
      DummyAuthorizationHandler.new({})
    end
    let(:helper) { Class.new(ActionView::Base).new }
    let(:builder) { described_class.new(:authorization_handler, record, helper, {}) }

    before do
      allow(helper).to receive(:authorizations_path).and_return("/authorizations")
    end

    def find(selector)
      subject.css(selector).first
    end

    describe "all_fields" do
      subject { Nokogiri::HTML(builder.all_fields) }

      it "includes the handler name" do
        expect(find("input#authorization_handler_handler_name")["value"]).to eq("dummy_authorization_handler")
      end

      it "includes the public handler attributes" do
        expect(find("input#date_field_authorization_handler_birthday")["type"]).to eq("text")
        expect(find("input#authorization_handler_birthday")["type"]).to eq("hidden")
        expect(find("input#authorization_handler_document_number")["type"]).to eq("text")
      end

      it "does not include other handler attributes" do
        expect(find("input#authorization_handler_id")).to eq(nil)
        expect(find("input#authorization_handler_user")).to eq(nil)
      end
    end

    describe "input" do
      it "renders a single field for an attribute" do
        html = Nokogiri::HTML(builder.input(:birthday))

        expect(html.css("label[for='authorization_handler_birthday']").length).to eq(1)
        expect(html.css("#date_field_authorization_handler_birthday").length).to eq(1)
        expect(html.css("input[type='text']").length).to eq(1)
        expect(html.css("#authorization_handler_birthday").length).to eq(1)
      end

      context "when specifying the input type" do
        it "renders it" do
          html = Nokogiri::HTML(builder.input(:document_number, as: :email_field))

          expect(html.css("label[for='authorization_handler_document_number']").length).to eq(1)
          expect(html.css(".label-required").length).to eq(1)
          expect(html.css("input[type='email']").length).to eq(1)
          expect(html.css(".form-error").length).to eq(1)
        end
      end
    end
  end
end
