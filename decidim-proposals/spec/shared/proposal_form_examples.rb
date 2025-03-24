# frozen_string_literal: true

shared_examples "a proposal form" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:title) do
    if options[:i18n] == false
      "More sidewalks and less roads!"
    else
      { en: "More sidewalks and less roads!" }
    end
  end
  let(:body) do
    if options[:i18n] == false
      "Everything would be better"
    else
      { en: "Everything would be better" }
    end
  end
  let(:body_template) { nil }
  let(:author) { create(:user, organization:) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:address) { nil }
  let(:suggested_hashtags) { [] }
  let(:attachment_params) { nil }
  let(:meeting_as_author) { false }
  let(:taxonomies) { [] }

  let(:params) do
    {
      title:,
      body:,
      body_template:,
      taxonomies:,
      author:,
      address:,
      meeting_as_author:,
      attachment: attachment_params,
      suggested_hashtags:
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_component: component,
      current_organization: component.organization,
      current_participatory_space: participatory_space
    )
  end

  describe "taxonomies" do
    let(:current_component) { component }

    it_behaves_like "a taxonomizable resource"
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  context "when there is no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }

    it "only adds errors to this field" do
      subject.valid?
      if options[:i18n]
        expect(subject.errors.attribute_names).to eq [:title_en]
      else
        expect(subject.errors.attribute_names).to eq [:title]
      end
    end
  end

  context "when the title is too long" do
    let(:title) do
      if options[:i18n] == false
        "A#{"a" * 200}"
      else
        { en: "A#{"a" * 200}" }
      end
    end

    it { is_expected.to be_invalid }
  end

  context "when the title is the minimum length" do
    let(:title) do
      if options[:i18n] == false
        "Length is right"
      else
        { en: "Length is right" }
      end
    end

    it { is_expected.to be_valid }
  end

  it_behaves_like "etiquette validator", fields: [:title, :body], **options

  context "when there is no body" do
    let(:body) { nil }

    it { is_expected.to be_invalid }
  end

  context "when the body exceeds the permitted length" do
    let(:component) { create(:proposal_component, :with_proposal_length, participatory_space:, proposal_length: allowed_length) }
    let(:allowed_length) { 15 }
    let(:body) { "A body longer than the permitted" }

    it { is_expected.to be_invalid } unless options[:admin]

    context "with carriage return characters that cause it to exceed" do
      let(:allowed_length) { 80 }
      let(:body) { "This text is just the correct length\r\nwith the carriage return characters removed" }

      it { is_expected.to be_valid }
    end
  end

  context "when there is a body template set" do
    let(:body_template) { "This is the template" }

    it { is_expected.to be_valid }

    context "when the template and the body are the same" do
      let(:body) { body_template }

      it { is_expected.to be_invalid } unless options[:admin]
    end
  end

  context "when geocoding is enabled" do
    let(:component) { create(:proposal_component, :with_geocoding_enabled, participatory_space:) }

    context "when the address is not present" do
      it "does not store the coordinates" do
        expect(subject).to be_valid
        expect(subject.address).to be_nil
        expect(subject.latitude).to be_nil
        expect(subject.longitude).to be_nil
      end
    end

    context "when the address is present" do
      let(:address) { "Some address" }

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      it "validates the address and store its coordinates" do
        expect(subject).to be_valid
        expect(subject.latitude).to eq(latitude)
        expect(subject.longitude).to eq(longitude)
      end
    end

    context "when latitude and longitude are manually set" do
      context "when the has address checkbox is unchecked" do
        it "is valid" do
          expect(subject).to be_valid
          expect(subject.latitude).to be_nil
          expect(subject.longitude).to be_nil
        end
      end

      context "when the proposal is unchanged" do
        let(:previous_proposal) { create(:proposal, address:) }

        let(:title) { translated(previous_proposal.title) }
        let(:body) { translated(previous_proposal.body) }

        let(:params) do
          {
            id: previous_proposal.id,
            title:,
            body:,
            author: previous_proposal.authors.first,
            taxonomies: previous_proposal.try(:taxonomies),
            address:,
            attachment: previous_proposal.try(:attachment_params),
            latitude:,
            longitude:
          }
        end

        it "is valid" do
          expect(subject).to be_valid
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end
    end
  end

  context "when the attachment is present" do
    let(:params) do
      {
        :title => title,
        :body => body,
        :author => author,
        :taxonomies => taxonomies,
        :address => address,
        :meeting_as_author => meeting_as_author,
        :suggested_hashtags => suggested_hashtags,
        attachments_key => [Decidim::Dev.test_file("city.jpeg", "image/jpeg")]
      }
    end
    let(:attachments_key) { :documents }

    it { is_expected.to be_valid }

    context "when the form has some errors" do
      let(:title) { nil }

      it "adds an error to the `:attachment` field" do
        expect(subject).not_to be_valid

        if options[:i18n]
          expect(subject.errors.full_messages).to contain_exactly("Title en cannot be blank")
          expect(subject.errors.attribute_names).to contain_exactly(:title_en)
        else
          expect(subject.errors.full_messages).to contain_exactly("Title cannot be blank", "Title is too short (under 15 characters)")
          expect(subject.errors.attribute_names).to contain_exactly(:title)
        end
      end
    end
  end

  describe "#extra_hashtags" do
    subject { form.extra_hashtags }

    let(:component) do
      create(
        :proposal_component,
        :with_extra_hashtags,
        participatory_space:,
        suggested_hashtags: component_suggested_hashtags,
        automatic_hashtags: component_automatic_hashtags
      )
    end
    let(:component_automatic_hashtags) { "" }
    let(:component_suggested_hashtags) { "" }

    it { is_expected.to eq([]) }

    context "when there are auto hashtags" do
      let(:component_automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }

      it { is_expected.to eq(%w(HashtagAuto1 HashtagAuto2)) }
    end

    context "when there are some suggested hashtags checked" do
      let(:component_suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2 HashtagSuggested3" }
      let(:suggested_hashtags) { %w(HashtagSuggested1 HashtagSuggested2) }

      it { is_expected.to eq(%w(HashtagSuggested1 HashtagSuggested2)) }
    end

    context "when there are invalid suggested hashtags checked" do
      let(:component_suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
      let(:suggested_hashtags) { %w(HashtagSuggested1 HashtagSuggested3) }

      it { is_expected.to eq(%w(HashtagSuggested1)) }
    end

    context "when there are both suggested and auto hashtags" do
      let(:component_automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }
      let(:component_suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
      let(:suggested_hashtags) { %w(HashtagSuggested2) }

      it { is_expected.to eq(%w(HashtagAuto1 HashtagAuto2 HashtagSuggested2)) }
    end
  end
end

shared_examples "a proposal form with meeting as author" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:proposal_component, participatory_space:) }
  let(:title) { { en: "More sidewalks and less roads!" } }
  let(:body) { { en: "Everything would be better" } }
  let(:created_in_meeting) { true }
  let(:meeting_component) { create(:meeting_component, participatory_space:) }
  let(:author) { create(:meeting, :published, component: meeting_component) }
  let!(:meeting_as_author) { author }

  let(:params) do
    {
      title:,
      body:,
      created_in_meeting:,
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

  context "when there is no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }
  end

  context "when the title is too long" do
    let(:title) do
      if options[:i18n] == false
        "A" * 200
      else
        { en: "A" * 200 }
      end
    end

    it { is_expected.to be_invalid }
  end

  it_behaves_like "etiquette validator", fields: [:title, :body], **options

  context "when there is no body" do
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
