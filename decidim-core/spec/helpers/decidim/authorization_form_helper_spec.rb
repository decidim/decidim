# frozen_string_literal: true
require "spec_helper"

module Decidim
  describe AuthorizationFormHelper do
    let(:record) do
      DummyAuthorizationHandler.new({})
    end

    before do
      allow(helper).to receive(:authorizations_path).and_return("/authorizations")
    end

    describe "authorization_form_for" do
      it "creates form" do
        form = helper.authorization_form_for(record) {|f| }
        expect(form).to include("<form")
        expect(form).to include("new_authorization_handler")
        expect(form).to include('action="/authorizations"')
        expect(form).to include('method="post"')
      end

      it "allows custom options" do
        form = helper.authorization_form_for(record, html: { class: "custom_form" }) {|f| }
        expect(form).to include('class="custom_form"')
      end
    end
  end
end
