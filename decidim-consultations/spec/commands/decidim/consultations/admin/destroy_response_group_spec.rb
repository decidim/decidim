# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Consultations
    module Admin
      describe DestroyResponseGroup do
        let(:response_group) { create :response_group }
        let(:command) { described_class.new(response_group) }

        describe "when the response_group is not present" do
          let(:response_group) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end

        context "when the response_group is not empty" do
          let!(:response) { create :response, response_group: }

          it "doesn't destroy the response_group" do
            expect do
              command.call
            end.not_to change(ResponseGroup, :count)
          end
        end

        describe "when the data is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "destroys the response_group in the process" do
            response_group
            expect do
              command.call
            end.to change(ResponseGroup, :count).by(-1)
          end
        end
      end
    end
  end
end
