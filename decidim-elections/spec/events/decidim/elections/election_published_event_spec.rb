# frozen_string_literal: true

require "spec_helper"

describe Decidim::Elections::ElectionPublishedEvent do
  # include Decidim::ElectionPathHelper

  include_context "when a simple event"
  def main_election_path(component)
    current_params = try(:params) || {}
    EngineRouter.main_proxy(component).root_path(locale: current_params[:locale])
  end

  let(:event_name) { "decidim.events.elections.election_published" }
  let(:resource) { create(:election) }
  # let(:participatory_space) { resource.participatory_space }
  let(:resource_path) { main_election_path(resource) }

  # participatory_space = resource.participatory_space

  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("The #{resource.title["en"]} election is now active for #{resource.participatory_space.title["en"]}.")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The #{resource.title["en"]} election is now active for #{resource.participatory_space.title["en"]}. You can see it from this page:")
    end
  end

  # describe "email_outro" do
  #   it "is generated correctly" do
  #     expect(subject.email_outro)
  #       .to include("You have received this notification because you are following #{participatory_space.title["en"]}")
  #   end
  # end

  # describe "notification_title" do
  #   it "is generated correctly" do
  #     expect(subject.notification_title)
  #       .to eq("The #{resource.name["en"]} election is now active for <a href=\"#{resource_path}\">#{participatory_space.title["en"]}</a>")
  #   end
  # end
end
