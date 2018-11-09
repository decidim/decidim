# frozen_string_literal: true

shared_examples "a proposal form" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:proposal_component, participatory_space: participatory_space) }
  let(:title) { "Oriol for president!" }
  let(:body) { "Everything would be better" }
  let(:author) { create(:user, organization: organization) }
  let(:user_group_id) { create(:user_group, :verified, users: [author], organization: organization).id }
  let(:category) { create(:category, participatory_space: participatory_space) }
  let(:scope) { create(:scope, organization: organization) }
  let(:category_id) { category.try(:id) }
  let(:scope_id) { scope.try(:id) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:has_address) { false }
  let(:address) { nil }
  let(:attachment_params) { nil }
  let(:params) do
    {
      title: title,
      body: body,
      author: author,
      category_id: category_id,
      scope_id: scope_id,
      address: address,
      has_address: has_address,
      attachment: attachment_params
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
          Geocoder::Lookup::Test.add_stub(
            address,
            [{ "latitude" => latitude, "longitude" => longitude }]
          )
        end

        it "validates the address and store its coordinates" do
          expect(subject).to be_valid
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end
    end

    if options && !options[:admin]
      context "when latitude and longitude are manually set" do
        let(:latitude) { 2.389643 }
        let(:longitude) { 48.8682538 }
        let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
        let(:params) do
          {
            title: title,
            body: body,
            author: author,
            category_id: category_id,
            scope_id: scope_id,
            has_address: has_address,
            address: address,
            attachment: attachment_params,
            latitude: latitude,
            longitude: longitude
          }
        end

        context "when the has address checkbox is unchecked" do
          let(:has_address) { false }

          it "is valid" do
            expect(subject).to be_valid
            expect(subject.latitude).to eq(latitude)
            expect(subject.longitude).to eq(longitude)
          end
        end

        context "when the proposal is unchanged" do
          let(:previous_proposal) { create(:proposal, address: address) }

          let(:params) do
            {
              id: previous_proposal.id,
              title: previous_proposal.title,
              body: previous_proposal.body,
              author: previous_proposal.author,
              category_id: previous_proposal.try(:category_id),
              scope_id: previous_proposal.try(:scope_id),
              has_address: has_address,
              address: address,
              attachment: previous_proposal.try(:attachment_params),
              latitude: latitude,
              longitude: longitude
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
      proposal = create(:proposal, component: component, author: author, decidim_user_group_id: user_group_id)

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
end
