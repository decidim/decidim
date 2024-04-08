# frozen_string_literal: true

require "spec_helper"

describe "Initiative embeds", type: :system do
  let(:state) { :published }
  let(:resource) { create(:initiative, state: state) }
  let(:widget_path) { Decidim::EngineRouter.main_proxy(resource).initiative_widget_path }

  it_behaves_like "an embed resource", skip_space_checks: true, skip_publication_checks: true

  context "when the user is the initiative author" do
    let(:organization) { resource.organization }
    let(:user) { resource.author }

    before do
      switch_to_host(organization.host)
    end

    context "when the state is created" do
      let(:state) { :created }

      it_behaves_like "not rendering the embed link in the resource page"

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end

    context "when the state is validating" do
      let(:state) { :validating }

      it_behaves_like "not rendering the embed link in the resource page"

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end

    context "when the state is discarded" do
      let(:state) { :discarded }

      # A discarded initiative is not available anymore to authors

      it_behaves_like "a 404 page" do
        let(:target_path) { widget_path }
      end
    end

    context "when the state is published" do
      let(:state) { :published }

      it_behaves_like "rendering the embed link in the resource page"
      it_behaves_like "rendering the embed page correctly"
    end

    context "when the state is rejected" do
      let(:state) { :rejected }

      it_behaves_like "rendering the embed link in the resource page"
      it_behaves_like "rendering the embed page correctly"
    end

    context "when the state is accepted" do
      let(:state) { :accepted }

      it_behaves_like "rendering the embed link in the resource page"
      it_behaves_like "rendering the embed page correctly"
    end
  end
end
