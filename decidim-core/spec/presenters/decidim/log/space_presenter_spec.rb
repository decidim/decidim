# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::SpacePresenter, type: :helper do
  subject { described_class.new(space, helper, extra).present }

  let(:space) { create(:participatory_process) }
  let(:extra) do
    {
      "title" => space.title
    }
  end
  let(:title) { h(extra["title"]["en"]) }
  let(:space_path) { Decidim::ResourceLocatorPresenter.new(space).path }

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when the space exists" do
    it "links to its public page" do
      expect(subject).to have_link(translated(space.title), href: space_path)
    end
  end

  context "when the space does not exist" do
    let(:space) { nil }
    let(:extra) do
      {
        "title" => {
          "en" => "My title"
        }
      }
    end

    it "does not link to its public page" do
      expect(subject).to have_no_link(title)
      expect(subject).to include(title)
    end
  end
end
