# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe HideResource do
      let(:reportable) { create(:dummy_resource, :reported) }
      let(:command) { described_class.new(reportable) }

      context "when everything is ok" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "hides the resource" do
          command.call
          expect(reportable.reload).to be_hidden
        end
      end

      context "when the resource is already hidden" do
        let(:reportable) { create(:dummy_resource, :hidden) }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
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
