# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a translated comment event" do
  describe "translated notifications" do
    let(:en_body) { "This is Sparta!" }
    let(:body) { { en: en_body, machine_translations: { ca: "C'est Sparta!" } } }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component:) }
    let(:comment) { create :comment, body:, commentable: }
    let(:en_version) { "<div><p>#{comment.body["en"]}</p></div>" }
    let(:machine_translated) { "<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>" }

    it_behaves_like "a translated event"
  end
end
