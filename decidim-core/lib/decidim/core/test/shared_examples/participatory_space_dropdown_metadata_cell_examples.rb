# frozen_string_literal: true

require "spec_helper"

shared_examples_for "participatory space dropdown metadata cell" do
  it "renders the space title" do
    expect(subject).to have_content(translated(model.title))
  end

  context "when there is a component" do
    let(:manifest_name) { "dummy" }
    let(:manifest) { Decidim.find_component_manifest(manifest_name) }
    let(:participatory_space) { model }
    let(:organization) { model.organization }
    let!(:component) do
      create(:component,
             manifest:,
             participatory_space:)
    end
    let(:resource) do
      create(:dummy_resource, component:, published_at: Time.current)
    end

    before do
      allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
        %w(Decidim::Dev::DummyResource)
      )
      allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
        %w(Decidim::Dev::DummyResource)
      )
    end

    it "renders the component link in the navigation menu" do
      within "ul.menu-bar__secondary-dropdown__menu" do
        expect(subject).to have_link(translated(component.name))
      end
    end

    context "when there are no activities" do
      it "does not render an activities block" do
        expect(subject).to have_no_css("div.activity__container")
      end
    end

    context "when there are activities related with components in other spaces" do
      let(:other_space) { create(:participatory_process, organization:) }
      let!(:other_component) do
        create(:component,
               manifest:,
               participatory_space: other_space)
      end
      let(:other_resource) do
        create(:dummy_resource, component: other_component, published_at: Time.current)
      end
      let!(:action_log) do
        create(
          :action_log,
          action: "publish",
          visibility: "all",
          resource: other_resource,
          organization:,
          participatory_space: other_space
        )
      end

      it "does not render an activities block" do
        expect(subject).to have_no_css("div.activity__container")
      end
    end

    context "when there are activities related with components of the space" do
      let!(:action_log) do
        create(:action_log, action: "publish", visibility: "all", resource:, organization:, participatory_space:)
      end

      it "renders the activities related with the component" do
        expect(subject).to have_css("div.activity__container")
      end
    end
  end
end
