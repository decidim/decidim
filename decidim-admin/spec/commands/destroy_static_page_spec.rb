# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe DestroyStaticPage do
    subject { described_class.new(page, user) }

    let!(:page) { create(:static_page) }
    let!(:user) { create(:user, organization: page.organization) }

    context "when everything is ok" do
      it "destroys the page" do
        subject.call
        expect(Decidim::StaticPage.where(id: page.id)).not_to exist
      end

      it "logs the action" do
        expect(Decidim::ActionLogger)
          .to receive(:log)
          .with("delete", user, page)

        subject.call
      end
    end
  end
end
