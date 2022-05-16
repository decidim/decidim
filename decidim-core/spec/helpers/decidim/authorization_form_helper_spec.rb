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
        options = {
          builder: AuthorizationFormBuilder,
          as: "authorization_handler",
          url: "/authorizations"
        }

        expect(helper).to receive(:decidim_form_for).with(record, options)

        helper.authorization_form_for(record) do
          # empty block to invoke the helper
        end
      end

      it "allows custom options" do
        options = {
          builder: AuthorizationFormBuilder,
          as: "authorization_handler",
          url: "/authorizations",
          html: {
            class: "custom_form"
          }
        }

        expect(helper).to receive(:decidim_form_for).with(record, options)

        helper.authorization_form_for(record, html: { class: "custom_form" }) do
          # empty block to invoke the helper
        end
      end
    end
  end
end
