# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Admin::ProposalNoteCreatedEvent do
  include_context "when a simple event"

  let(:resource) { create(:proposal, title: Faker::Lorem.characters(number: 25)) }
  let(:resource_title) { translated(resource.title) }
  let(:event_name) { "decidim.events.proposals.admin.proposal_note_replied" }
  let(:component) { resource.component }
  let(:author) { create(:user, :confirmed, :admin, organization:) }
  let(:extra) { { note_author_id: author.id } }
  let(:admin_proposal_info_path) { "/admin/participatory_processes/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}" }
  let(:admin_proposal_info_url) { "http://#{organization.host}/admin/participatory_processes/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}?locale=#{I18n.locale}" }
  let(:email_subject) { "#{author.name} has replied your private note in #{resource_title}." }
  let(:email_intro) { %(#{author.name} has replied your private note in #{resource_title}. Check it out at <a href="#{admin_proposal_info_url}">the admin panel</a>.) }
  let(:email_outro) { "You have received this notification because you are the author of the note." }
  let(:notification_title) { %(<a href="/profiles/#{author.nickname}">#{author.name} @#{author.nickname}</a> has replied your private note in <a href="#{resource_path}">#{resource_title}</a>. Check it out at <a href="#{admin_proposal_info_path}">the admin panel</a>.) }

  it_behaves_like "a simple event"
  it_behaves_like "a simple event email"
  it_behaves_like "a simple event notification"

  context "when proposals component added to assemblies participatory space" do
    let(:assembly) { create(:assembly) }
    let(:proposal_component) { create(:proposal_component, participatory_space: assembly) }
    let(:resource) { create(:proposal, component: proposal_component, title: Faker::Lorem.characters(number: 25)) }
    let(:admin_proposal_info_path) { "/admin/assemblies/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}" }
    let(:admin_proposal_info_url) { "http://#{organization.host}/admin/assemblies/#{participatory_space.slug}/components/#{component.id}/manage/proposals/#{resource.id}?locale=#{I18n.locale}" }
    let(:email_intro) { %(#{author.name} has replied your private note in #{resource_title}. Check it out at <a href="#{admin_proposal_info_url}">the admin panel</a>.) }
    let(:notification_title) { %(<a href="/profiles/#{author.nickname}">#{author.name} @#{author.nickname}</a> has replied your private note in <a href="#{resource_path}">#{resource_title}</a>. Check it out at <a href="#{admin_proposal_info_path}">the admin panel</a>.) }

    it_behaves_like "a simple event email"
    it_behaves_like "a simple event notification"
  end
end
