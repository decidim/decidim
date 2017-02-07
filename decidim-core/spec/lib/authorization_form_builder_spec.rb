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
        expect(find("input#authorization_handler_handler_name")["value"]).to eq("decidim/dummy_authorization_handler")
      end

      it "includes the public handler attributes" do
        expect(find("input#authorization_handler_birthday")["type"]).to eq("date")
        expect(find("input#authorization_handler_document_number")["type"]).to eq("text")
      end

      it "does not include other handler attributes" do
        expect(find("input#authorization_handler_id")).to eq(nil)
        expect(find("input#authorization_handler_user")).to eq(nil)
      end
    end

    describe "input" do
      it "renders a single field for an attribute" do
        html = builder.input(:birthday)
        expect(html).to eq('<label for="authorization_handler_birthday">Birthday<input type="date" name="authorization_handler[birthday]" id="authorization_handler_birthday" /></label>')
      end

      context "specifying the input type" do
        it "renders it" do
          html = builder.input(:document_number, as: :email_field)
          expect(html).to eq('<label for="authorization_handler_document_number">Document number<input required="required" type="email" name="authorization_handler[document_number]" id="authorization_handler_document_number" /><span class="form-error">There&#39;s an error in this field.</span></label>')
        end
      end
    end
  end
end
