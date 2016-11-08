# frozen_string_literal: true
require "spec_helper"

module Decidim
  module Admin
    describe CreatePage, :db do
      describe "call" do
        let(:organization) { create(:organization) }
        let(:form) { PageForm.from_model(build(:page, organization: organization)) }
        let(:command) { described_class.new(form) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a page" do
            expect do
              command.call
            end.to_not change { Page.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a page in the organization" do
            expect do
              command.call
            end.to change { organization.pages.count }.by(1)
          end
        end
      end
    end
  end
end
