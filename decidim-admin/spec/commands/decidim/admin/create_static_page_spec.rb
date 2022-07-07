# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateStaticPage do
    describe "call" do
      let(:organization) { create(:organization) }
      let(:user) { create :user, :admin, :confirmed, organization: organization }
      let(:form) do
        StaticPageForm
          .from_model(build(:static_page))
          .with_context(current_user: user, current_organization: organization)
      end
      let(:command) { described_class.new(form) }

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a page" do
          expect do
            command.call
          end.not_to change(Decidim::StaticPage, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "uses traceability to create the page", versioning: true do
          expect(Decidim.traceability)
            .to receive(:create!)
            .with(Decidim::StaticPage, user, hash_including(:title, :slug, :content, :organization, :allow_public_access))
            .and_call_original

          expect { command.call }.to change(Decidim::ActionLog, :count)

          action_log = Decidim::ActionLog.last
          expect(action_log.version).to be_present
          expect(action_log.version.event).to eq "create"
        end

        it "creates a page in the organization" do
          expect do
            command.call
          end.to change(organization.static_pages, :count).by(1)
        end
      end
    end
  end
end
