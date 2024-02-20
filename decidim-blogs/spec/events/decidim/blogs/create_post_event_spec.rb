# frozen_string_literal: true

require "spec_helper"

describe Decidim::Blogs::CreatePostEvent do
  include_context "when a simple event"

  let(:resource) { create(:post, title: generate_localized_title(:blog_title)) }
  let(:event_name) { "decidim.events.blogs.post_created" }
  let(:email_intro) { "The post \"#{resource_title}\" has been published in \"#{participatory_space_title}\" that you are following." }
  let(:email_outro) { "You have received this notification because you are following \"#{participatory_space_title}\". You can unfollow it from the previous link." }
  let(:notification_title) { "The post <a href=\"#{resource_path}\">#{resource_title}</a> has been published in #{participatory_space_title}" }
  let(:email_subject) { "New post published in #{participatory_space_title}" }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  describe "resource_text" do
    it "returns the post body" do
      expect(subject.resource_text).to eq translated(resource.body)
    end
  end
end
