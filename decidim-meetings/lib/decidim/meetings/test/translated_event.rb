# frozen_string_literal: true

shared_examples_for "a translated meeting event" do
  describe "translated notifications" do
    let(:en_body) { "This is Sparta!" }
    let(:body) { { en: en_body, machine_translations: { ca: "C'est Sparta!" } } }
    let(:participatory_process) { create :participatory_process, organization: }
    let(:meeting_component) { create(:meeting_component, participatory_space: participatory_process) }
    let(:translatable) { true }
    let(:en_version) { resource.description["en"] }
    let(:machine_translated) { resource.description["machine_translations"]["ca"] }

    let(:resource) do
      create :meeting,
             component: meeting_component,
             title: { en: "A nice event", machine_translations: { ca: "Une belle event" } },
             description: body
    end

    it_behaves_like "a translated event"
  end
end
