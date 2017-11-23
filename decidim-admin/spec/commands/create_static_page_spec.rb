# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateStaticPage do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:form) { StaticPageForm.from_model(build(:static_page)).with_context(current_organization: organization) }
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
          end.not_to change { Decidim::StaticPage.count }
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a page in the organization" do
          expect do
            command.call
          end.to change { organization.static_pages.count }.by(1)
        end
      end
    end
  end
end
