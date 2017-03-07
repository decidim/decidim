# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe UnreportResource do
      let(:reportable) { create(:dummy_resource, :reported) }
      let(:command) { described_class.new(reportable) }

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "resets the report count" do
          command.call
          expect(reportable.reload.report_count).to eq(0)
        end

        context "when the resource is hidden" do
          let(:reportable) { create(:dummy_resource, :reported, :hidden) }

          it "unhides the resource" do
            command.call
            expect(reportable.reload).not_to be_hidden
          end
        end
      end

      context "when the resource is not reported" do
        let(:reportable) { create(:dummy_resource) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
