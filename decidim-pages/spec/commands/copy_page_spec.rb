# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Pages
    describe CopyPage, :db do
      describe "call" do
        let(:feature) { create(:feature, manifest_name: "pages") }
        let!(:page) { create(:page, feature: feature) }
        let(:new_feature) {create(:feature, manifest_name: "pages")}
        let(:context) { {new_feature: new_feature, old_feature: feature} }
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
            end.not_to change { Page.count }
          end
        end

        describe "when the page is duplicated" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "duplicates the page and its values" do
            expect(Page).to receive(:create!).with(feature: new_feature, body: page.body).and_call_original

            expect do
              command.call
            end.to change { Page.count }.by(1)
          end
        end
      end
    end
  end
end
