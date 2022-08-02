# frozen_string_literal: true

require "spec_helper"

describe Decidim::UserActivityCell, type: :cell do
  include Decidim::ApplicationHelper
  include Decidim::TranslationsHelper

  subject { my_cell.call }

  let(:my_cell) do
    cell(
      "decidim/user_activity",
      model,
      context: {
        activities:,
        filter:,
        resource_types:,
        user: model
      }
    )
  end
  let(:model) { create(:user, :confirmed, organization: component.organization) }
  let(:resource_types) do
    %w(
      Decidim::Proposals::CollaborativeDraft
      Decidim::Comments::Comment
      Decidim::Debates::Debate
      Decidim::Initiative
      Decidim::Meetings::Meeting
      Decidim::Blogs::Post
      Decidim::Proposals::Proposal
      Decidim::Consultations::Question
    )
  end
  let(:filter) { Decidim::FilterResource::Filter.new({ resource_type: resource_types }) }
  let(:current_user) { nil }
  let(:component) { create(:component, :published) }
  let(:commentable) { create(:dummy_resource, component:, published_at: Time.current) }
  let(:comments) { create_list(:comment, 15, author: model, commentable:) }
  let(:activities) do
    Decidim::PublicActivities.new(
      component.organization,
      user: model,
      current_user:,
      resource_type: "all",
      resource_name: filter.resource_type
    ).query.page(current_page).per(10)
  end
  let(:current_page) { 1 }
  let!(:logs) do
    comments.map do |comment|
      create(
        :action_log,
        action: "publish",
        visibility: "all",
        user: model,
        resource: comment,
        organization: component.organization,
        participatory_space: component.participatory_space
      )
    end
  end
  let(:controller) { double }

  def redesigned_layout(name)
    name
  end

  before do
    allow(controller).to receive(:current_organization).and_return(component.organization)
    allow(controller).to receive(:redesign_enabled?).and_return(true)

    allow(my_cell).to receive(:url_for).and_return("/")
    allow(my_cell).to receive(:params).and_return(ActionController::Parameters.new({}))
    allow(my_cell).to receive(:controller).and_return(controller)
  end

  it "displays the latest items on the first page and a pagination" do
    logs.last(10).each do |log|
      root_link = Decidim::ResourceLocatorPresenter.new(log.resource.root_commentable).path
      comment_link = "#{root_link}?commentId=#{log.resource.id}"
      title = html_truncate(translated_attribute(log.resource.root_commentable.title), length: 80)

      expect(subject).to have_link(title, href: comment_link)
    end

    within "#decidim-paginate-container .pagination" do
      expect(page).to have_selector("li.page.current", text: "1")
      expect(page).to have_selector("li.page a", text: "2")
      expect(page).not_to have_selector("li.page a", text: "3")
    end
  end

  context "when on the second page" do
    let(:current_page) { 2 }

    it "displays the oldest items and a pagination" do
      logs.first(5).each do |log|
        root_link = Decidim::ResourceLocatorPresenter.new(log.resource.root_commentable).path
        comment_link = "#{root_link}?commentId=#{log.resource.id}"
        title = html_truncate(translated_attribute(log.resource.root_commentable.title), length: 80)

        expect(subject).to have_link(title, href: comment_link)
      end

      within "#decidim-paginate-container .pagination" do
        expect(page).to have_selector("li.page a", text: "1")
        expect(page).to have_selector("li.page.current", text: "2")
      end
    end
  end

  context "when there are moderated activity items that would span on the second page" do
    before do
      logs.first(5).each do |log|
        create(
          :moderation,
          :hidden,
          reportable: log.resource,
          participatory_space: log.resource.commentable.participatory_space
        )
      end
    end

    it "displays only the non-moderated items on the first page without a pagination" do
      # The first five items should be hidden through moderation
      logs.first(5).each do |log|
        root_link = Decidim::ResourceLocatorPresenter.new(log.resource.root_commentable).path
        comment_link = "#{root_link}?commentId=#{log.resource.id}"
        title = html_truncate(translated_attribute(log.resource.root_commentable.title), length: 80)

        expect(subject).not_to have_link(title, href: comment_link)
      end
      logs.last(10).each do |log|
        root_link = Decidim::ResourceLocatorPresenter.new(log.resource.root_commentable).path
        comment_link = "#{root_link}?commentId=#{log.resource.id}"
        title = html_truncate(translated_attribute(log.resource.root_commentable.title), length: 80)

        expect(subject).to have_link(title, href: comment_link)
      end

      expect(subject).not_to have_selector("#decidim-paginate-container .pagination")
    end
  end
end
