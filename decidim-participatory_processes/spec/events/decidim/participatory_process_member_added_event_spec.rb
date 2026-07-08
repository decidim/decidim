# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcessMemberAddedEvent do
  include_context "when a simple event"
  include Rails.application.routes.mounted_helpers

  let(:participatory_space) { resource }
  let(:event_name) { "decidim.events.participatory_space.member_added" }
  let(:role) { create(:member, user:, participatory_space:) }
  let(:extra) { { role: } }
  let(:email_subject) { "You now have access to #{resource_title}." }
  let(:email_outro) { "You have received this notification because an administrator has added you to <a href=\"#{resource_url}\">#{resource_title}</a>. If access to this space is restricted, you will be able to access it with your account." }
  let(:email_intro) { "You have been added as a member to a participatory space." }
  let(:notification_title) { "You now have access to <a href=\"#{resource_url}\">#{resource_title}</a>." }

  let(:host) { participatory_space.organization.host }
  let(:members_page) { decidim_participatory_processes.participatory_process_members_url(participatory_space, host:) }

  context "when membership is published" do
    let(:role) { create(:member, :published, user:, participatory_space:) }
    let(:i18n_scope) { "#{event_name}.published" }
    let(:email_outro) { "You have received this notification because an administrator has added you to <a href=\"#{resource_url}\">#{resource_title}</a>. If access to this space is restricted, you will be able to access it with your account.<br> Your profile will appear in the <a href=\"#{members_page}\">list of members</a> of the space." }

    context "when participatory process is transparent" do
      let(:resource) { create(:participatory_process, :transparent, title: generate_localized_title(:participatory_process_title)) }

      it_behaves_like "a simple event" do
        let(:i18n_scope) { "#{event_name}.published" }
      end
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end

    context "when participatory process is restricted" do
      let(:resource) { create(:participatory_process, :restricted, title: generate_localized_title(:participatory_process_title)) }
      let(:i18n_scope) { event_name }

      it_behaves_like "a simple event" do
        let(:i18n_scope) { "#{event_name}.published" }
      end
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end

  context "when membership is public" do
    let(:role) { create(:member, :unpublished, user:, participatory_space:) }
    let(:i18n_scope) { "#{event_name}.unpublished" }

    context "when participatory process is transparent" do
      let(:resource) { create(:participatory_process, :transparent, title: generate_localized_title(:participatory_process_title)) }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end

    context "when participatory process is restricted" do
      let(:resource) { create(:participatory_process, :restricted, title: generate_localized_title(:participatory_process_title)) }

      it_behaves_like "a simple event"
      it_behaves_like "a simple event email"
      it_behaves_like "a simple event notification"
    end
  end
end
