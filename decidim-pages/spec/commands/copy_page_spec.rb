# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Pages
    describe CopyPage do
      describe "call" do
        let(:component) { create(:component, manifest_name: "pages") }
        let!(:page) { create(:page, component:) }
        let(:new_component) { create(:component, manifest_name: "pages") }
        let(:context) { { new_component:, old_component: component } }
        let(:command) { described_class.new(context) }

        describe "when the page is not duplicated" do
          before do
            allow(Page).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't duplicate the page" do
            expect do
              command.call
            end.not_to change(Page, :count)
          end
        end

        describe "when the page is duplicated" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "duplicates the page and its values" do
            expect(Page).to receive(:create!).with(component: new_component, body: page.body).and_call_original

            expect do
              command.call
            end.to change(Page, :count).by(1)
          end
        end
      end
    end
  end
end
