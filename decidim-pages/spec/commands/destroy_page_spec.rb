# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe DestroyPage do
      describe "call" do
        let(:component) { create(:component, manifest_name: "pages") }
        let!(:page) { create(:page, component:) }
        let(:command) { described_class.new(component) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "deletes the page associated to the component" do
          expect do
            command.call
          end.to change(Page, :count).by(-1)
        end
      end
    end
  end
end
