# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe StaticPageTopic do
    describe "#accessible_pages_for" do
      it_behaves_like "accessible static pages" do
        subject { create(:static_page_topic, organization:) }

        let!(:public_pages) do
          create_list(
            :static_page,
            5,
            organization:,
            topic: subject,
            allow_public_access: true
          )
        end
        let!(:private_pages) do
          create_list(:static_page, 5, organization:, topic: subject)
        end
        let(:actual_page_ids) do
          subject.accessible_pages_for(user).pluck(:id)
        end
      end
    end
  end
end
