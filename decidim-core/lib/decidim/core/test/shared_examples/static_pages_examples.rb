# frozen_string_literal: true

require "spec_helper"

shared_examples "accessible static pages" do
  let(:organization) do
    create(
      :organization,
      create_static_pages: false,
      force_users_to_authenticate_before_access_organization: true
    )
  end
  let!(:public_pages) { create_list(:static_page, 5, organization:, allow_public_access: true) }
  let!(:private_pages) { create_list(:static_page, 5, organization:) }
  let(:actual_page_ids) { [] }

  def expect_correct_accessible_static_pages
    expect(actual_page_ids).to match_array(expected_page_ids)
  end

  context "with a user" do
    let(:user) { create(:user, organization:) }
    let(:expected_page_ids) { public_pages.pluck(:id) + private_pages.pluck(:id) }

    it { expect_correct_accessible_static_pages }
  end

  context "without a user" do
    let(:user) { nil }
    let(:expected_page_ids) { public_pages.pluck(:id) }

    it { expect_correct_accessible_static_pages }

    context "when the organization does not force users to authenticate" do
      let(:organization) { create(:organization, create_static_pages: false) }
      let(:expected_page_ids) do
        public_pages.pluck(:id) + private_pages.pluck(:id)
      end

      it { expect_correct_accessible_static_pages }
    end
  end
end
