# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Pages
    describe CreatePage, :db do
      describe "call" do
        let(:feature) { create(:feature, manifest_name: "pages") }
        let(:command) { described_class.new(feature) }

        describe "when the page is not saved" do
          before do
            expect_any_instance_of(Page).to receive(:save).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a page" do
            expect do
              command.call
            end.not_to change { Page.count }
          end
        end

        describe "when the page is saved" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new page with the same name as the feature" do
            expect(Page).to receive(:new).with({
              title: feature.name,
              feature: feature
            }).and_call_original
            
            expect do
              command.call
            end.to change { Page.count }.by(1)
          end
        end
      end
    end
  end
end
