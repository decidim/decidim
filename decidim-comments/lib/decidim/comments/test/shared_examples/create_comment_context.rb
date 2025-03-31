# frozen_string_literal: true

RSpec.shared_context "when creating a comment" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:user) { create(:user, organization:) }
  let(:author) { create(:user, organization:) }
  let(:current_user) { author }
  let(:dummy_resource) { create(:dummy_resource, component:) }
  let(:commentable) { dummy_resource }
  let(:body) { Faker::Lorem.paragraph }
  let(:alignment) { 1 }
  let(:form_params) do
    {
      "comment" => {
        "body" => body,
        "alignment" => alignment,
        "commentable" => commentable
      }
    }
  end
  let(:form) do
    Decidim::Comments::CommentForm.from_params(
      form_params
    ).with_context(
      current_organization: organization, current_user:
    )
  end
  let(:command) { described_class.new(form) }
end
