# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ResourcePresenter, type: :helper do
  subject { presenter.present }

  let(:presenter) { described_class.new(resource, helper, extra) }
  let(:resource) { create(:dummy_resource, title: { en: "Jeffery O'Conner 246" }) }
  let(:extra) do
    {
      "title" => resource.title
    }
  end
  let(:title) { translated extra["title"] }
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when the resource exists" do
    it "links to its public page" do
      expect(subject).to have_link(title, href: resource_path)
    end
  end

  context "when the resource doesn't exist" do
    let(:resource) { nil }
    let(:extra) do
      {
        "title" => "My title"
      }
    end

    it "doesn't link to its public page" do
      expect(subject).not_to have_link(title)
      expect(subject).to include(h(title))
    end
  end

  context "when the resource path is not found" do
    it "doesn't link to its public page" do
      allow(presenter).to receive(:resource_path).and_return(nil)

      expect(subject).not_to have_link(title)
      expect(subject).to include(h(title))
    end
  end
end
