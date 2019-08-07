# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ReplaceButtonsHelper do
    describe "#submit_tag" do
      it "uses a button instead of an input" do
        button = helper.submit_tag("Save", class: "test")
        expect(button).to have_tag('button[class="test"][type="submit"][name="commit"]')
      end
    end

    describe "#button_to" do
      it "uses a button instead of an input when not provided with a block" do
        button = helper.button_to("Link", "#")
        expect(button).to have_tag('form[action="#"] button[type="submit"]')
      end

      it "uses a button instead of an input when provided with a block" do
        button = helper.button_to("#") { "Link" }
        expect(button).to have_tag('form[action="#"] button[type="submit"]')
      end
    end
  end
end
