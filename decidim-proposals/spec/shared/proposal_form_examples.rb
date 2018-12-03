# frozen_string_literal: true

shared_examples "a proposal form" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:proposal_component, participatory_space: participatory_space) }
  let(:title) { "More sidewalks and less roads!" }
  let(:body) { "Everything would be better" }
  let(:author) { create(:user, organization: organization) }
  let(:user_group) { create(:user_group, :verified, users: [author], organization: organization) }
  let(:user_group_id) { user_group.id }
  let(:category) { create(:category, participatory_space: participatory_space) }
  let(:scope) { create(:scope, organization: organization) }
  let(:category_id) { category.try(:id) }
  let(:scope_id) { scope.try(:id) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:has_address) { false }
  let(:address) { nil }
  let(:hashtags_suggested) { [] }
  let(:attachment_params) { nil }
  let(:meeting_as_author) { false }
  let(:params) do
    {
      title: title,
      body: body,
      author: author,
      category_id: category_id,
      scope_id: scope_id,
      address: address,
      has_address: has_address,
      meeting_as_author: meeting_as_author,
      attachment: attachment_params,
      hashtags_suggested: hashtags_suggested
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_component: component,
      current_organization: component.organization,
      current_participatory_space: participatory_space
    )
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when there's no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }

    it "only adds errors to this field" do
      subject.valid?
      expect(subject.errors.keys).to eq [:title]
    end
  end

  context "when the title is too long" do
    let(:body) { "A" * 200 }

    it { is_expected.to be_invalid }
  end

  context "when the body is not etiquette-compliant" do
    let(:body) { "A" }

    it { is_expected.to be_invalid }
  end

  context "when there's no body" do
    let(:body) { nil }

    it { is_expected.to be_invalid }
  end

  context "when no category_id" do
    let(:category_id) { nil }

    it { is_expected.to be_valid }
  end

  context "when no scope_id" do
    let(:scope_id) { nil }

    it { is_expected.to be_valid }
  end

  context "with invalid category_id" do
    let(:category_id) { 987 }

    it { is_expected.to be_invalid }
  end

  context "with invalid scope_id" do
    let(:scope_id) { 987 }

    it { is_expected.to be_invalid }
  end

  context "when geocoding is enabled" do
    let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space: participatory_space) }

    context "when the has address checkbox is checked" do
      let(:has_address) { true }

      context "when the address is not present" do
        it { is_expected.to be_invalid }
      end

      context "when the address is present" do
        let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }

        before do
          stub_geocoding(address, [latitude, longitude])
        end

        it "validates the address and store its coordinates" do
          expect(subject).to be_valid
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end
    end
  end

  describe "category" do
    subject { form.category }

    context "when the category exists" do
      it { is_expected.to be_kind_of(Decidim::Category) }
    end

    context "when the category does not exist" do
      let(:category_id) { 7654 }

      it { is_expected.to eq(nil) }
    end

    context "when the category is from another process" do
      let(:category_id) { create(:category).id }

      it { is_expected.to eq(nil) }
    end
  end

  describe "scope" do
    subject { form.scope }

    context "when the scope exists" do
      it { is_expected.to be_kind_of(Decidim::Scope) }
    end

    context "when the scope does not exist" do
      let(:scope_id) { 3456 }

      it { is_expected.to eq(nil) }
    end

    context "when the scope is from another organization" do
      let(:scope_id) { create(:scope).id }

      it { is_expected.to eq(nil) }
    end

    context "when the participatory space has a scope" do
      let(:parent_scope) { create(:scope, organization: organization) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization, scope: parent_scope) }
      let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

      context "when the scope is descendant from participatory space scope" do
        it { is_expected.to eq(scope) }
      end

      context "when the scope is not descendant from participatory space scope" do
        let(:scope) { create(:scope, organization: organization) }

        it { is_expected.to eq(scope) }

        it "makes the form invalid" do
          expect(form).to be_invalid
        end
      end
    end
  end

  it "properly maps category id from model" do
    proposal = create(:proposal, component: component, category: category)

    expect(described_class.from_model(proposal).category_id).to eq(category_id)
  end

  if options && options[:user_group_check]
    it "properly maps user group id from model" do
      proposal = create(:proposal, component: component, users: [author], user_groups: [user_group])

      expect(described_class.from_model(proposal).user_group_id).to eq(user_group_id)
    end
  end

  context "when the attachment is present" do
    let(:attachment_params) do
      {
        title: "My attachment",
        file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
      }
    end

    it { is_expected.to be_valid }

    context "when the form has some errors" do
      let(:title) { nil }

      it "adds an error to the `:attachment` field" do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(["Title can't be blank", "Attachment Needs to be reattached"])
        expect(subject.errors.keys).to match_array([:title, :attachment])
      end
    end
  end

  describe "#extra_hashtags" do
    subject { form.extra_hashtags }

    let(:component) do
      create(
        :proposal_component,
        :with_extra_hashtags,
        participatory_space: participatory_space,
        hashtags_suggested: component_hashtags_suggested,
        hashtags_auto: component_hashtags_auto
      )
    end
    let(:component_hashtags_auto) { "" }
    let(:component_hashtags_suggested) { "" }

    it { is_expected.to eq([]) }

    context "when there are auto hashtags" do
      let(:component_hashtags_auto) { "HashtagAuto1 HashtagAuto2" }

      it { is_expected.to eq(%w(HashtagAuto1 HashtagAuto2)) }
    end

    context "when there are some suggested hashtags checked" do
      let(:component_hashtags_suggested) { "HashtagSuggested1 HashtagSuggested2 HashtagSuggested3" }
      let(:hashtags_suggested) { %w(HashtagSuggested1 HashtagSuggested2) }

      it { is_expected.to eq(%w(HashtagSuggested1 HashtagSuggested2)) }
    end

    context "when there are invalid suggested hashtags checked" do
      let(:component_hashtags_suggested) { "HashtagSuggested1 HashtagSuggested2" }
      let(:hashtags_suggested) { %w(HashtagSuggested1 HashtagSuggested3) }

      it { is_expected.to eq(%w(HashtagSuggested1)) }
    end

    context "when there are both suggested and auto hashtags" do
      let(:component_hashtags_auto) { "HashtagAuto1 HashtagAuto2" }
      let(:component_hashtags_suggested) { "HashtagSuggested1 HashtagSuggested2" }
      let(:hashtags_suggested) { %w(HashtagSuggested2) }

      it { is_expected.to eq(%w(HashtagAuto1 HashtagAuto2 HashtagSuggested2)) }
    end
  end
end

shared_examples "a proposal form with meeting as author" do |_options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:proposal_component, participatory_space: participatory_space) }
  let(:title) { "More sidewalks and less roads!" }
  let(:body) { "Everything would be better" }
  let(:created_in_meeting) { true }
  let(:meeting_component) { create(:meeting_component, participatory_space: participatory_space) }
  let(:author) { create(:meeting, component: meeting_component) }
  let!(:meeting_as_author) { author }

  let(:params) do
    {
      title: title,
      body: body,
      created_in_meeting: created_in_meeting,
      author: meeting_as_author,
      meeting_id: author.id
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_component: component,
      current_organization: component.organization,
      current_participatory_space: participatory_space
    )
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when there's no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }
  end

  context "when the title is too long" do
    let(:body) { "A" * 200 }

    it { is_expected.to be_invalid }
  end

  context "when the body is not etiquette-compliant" do
    let(:body) { "A" }

    it { is_expected.to be_invalid }
  end

  context "when there's no body" do
    let(:body) { nil }

    it { is_expected.to be_invalid }
  end

  context "when proposals comes from a meeting" do
    it "validates the meeting as author" do
      expect(subject).to be_valid
      expect(subject.author).to eq(author)
    end
  end
end
