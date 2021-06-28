# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::UserResourcePresenter, type: :helper do
  subject { presenter.present }

  let(:presenter) { described_class.new(resource, helper, extra) }
  let(:resource) { create(:user, :confirmed) }
  let(:extra) do
    {
      "title" => resource.name
    }
  end

  before do
    helper.extend(Decidim::ApplicationHelper)
    helper.extend(Decidim::TranslationsHelper)
  end

  context "when the resource is an existing user" do
    it "presents the user name" do
      expect(subject).to include(h(resource.name))
    end
  end

  context "when the resource is a blocked user" do
    let(:resource) { create(:user, :blocked) }

    it "presents the original user name" do
      expect(subject).not_to include("Blocked user")
      expect(subject).to include(h(resource.user_name))
    end
  end

  context "when the resource is not a user" do
    let(:resource) { create(:dummy_resource, title: { en: "Jeffery O'Conner 246" }) }
    let(:extra) do
      {
        "title" => "My title"
      }
    end
    let(:title) { translated extra["title"] }

    it "presents the extra title instead" do
      expect(subject).to include(h(title))
    end
  end
end
