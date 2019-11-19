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
        expect(find("input#authorization_handler_date_of_birth")["data-date-format"]).to eq("dd/mm/yyyy")
        expect(find("input#authorization_handler_postal_code")["type"]).to eq("text")
        expect(find("input#authorization_handler_document_number")["type"]).to eq("text")
        expect(find("input#authorization_handler_name_and_surname")["type"]).to eq("text")
      end

      it "does not include other handler attributes" do
        expect(find("input#authorization_handler_id")).to eq(nil)
        expect(find("input#authorization_handler_user")).to eq(nil)
      end

      context "when there are scopes" do
        let(:user) { create(:user) }
        let!(:scope) { create(:scope, organization: user.organization) }
        let(:record) do
          DummyAuthorizationHandler.new(user: user)
        end

        it "includes a scopes selector" do
          expect(find("select#authorization_handler_scope_id").children.first["value"]).to eq(scope.id.to_s)
        end
      end
    end

    describe "input" do
      it "renders a single field for an attribute" do
        html = Nokogiri::HTML(builder.input(:date_of_birth))

        expect(html.css("label[for='authorization_handler_date_of_birth']").length).to eq(1)
        expect(html.css("input[type='text']").length).to eq(1)
        expect(html.css("#authorization_handler_date_of_birth").length).to eq(1)
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

    describe "public_attributes (private)" do
      subject { builder.send(:public_attributes) }

      let(:public_attributes) do
        {
          handler_name: String,
          document_number: String,
          postal_code: String,
          date_of_birth: Date,
          scope_id: Integer,
          name_and_surname: String
        }
      end

      it { is_expected.to match_array(public_attributes) }
    end
  end
end
