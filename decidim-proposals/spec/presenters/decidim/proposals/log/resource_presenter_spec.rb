# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Log::ResourcePresenter, type: :helper do
  let(:presenter) { described_class.new(resource, helper, extra) }
  let(:resource) { create(:proposal, title: Faker::Book.unique.title) }
  let(:extra) do
    {
      "title" => Faker::Book.unique.title
    }
  end
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when the resource exists" do
    it "links to its public page with the name of the proposal" do
      html = presenter.present
      expect(html).to have_link(translated(resource.title), href: resource_path)
    end
  end

  context "when the resource doesn't exist" do
    let(:resource) { nil }
    let(:extra) do
      {
        "title" => "My title"
      }
    end

    it "doesn't link to its public page but renders its name" do
      expect(presenter.present).not_to have_link("My title")
    end
  end
end
