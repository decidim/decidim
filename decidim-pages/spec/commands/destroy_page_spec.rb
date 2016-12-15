# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Pages
    describe DestroyPage, :db do
      describe "call" do
        let(:feature) { create(:feature) }
        let!(:page)   { create(:page, feature: feature) }
        let(:command) { described_class.new(feature) }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "deletes the page associated to the feature" do
          expect do
            command.call
          end.to change { Page.count }.by(-1)
        end
      end
    end
  end
end
