# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blogs::CreatePostEvent do
  let(:resource) { create :post }
  let(:event_name) { "decidim.events.blogs.post_created" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    let(:assembly) { create(:assembly, organization: organization, title: { en: "It's a test" }) }
    let(:blogs_component) { create :component, :published, name: { en: "Blogs" }, participatory_space: assembly, manifest_name: :blogs }

    before do
      resource.component = blogs_component
      resource.save!
    end

    it "is generated correctly" do
      expect(subject.email_subject).to eq("New post published in #{participatory_space_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("The post \"#{resource_title}\" has been published in \"#{participatory_space_title}\" that you are following.")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to include("You have received this notification because you are following \"#{participatory_space_title}\"")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to eq("The post <a href=\"#{resource_path}\">#{resource_title}</a> has been published in #{participatory_space_title}")
    end
  end

  describe "resource_text" do
    it "returns the post body" do
      expect(subject.resource_text).to eq translated(resource.body)
    end
  end
end
