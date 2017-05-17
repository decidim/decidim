# frozen_string_literal: true
RSpec.shared_examples "with participatory processes" do
  before do
    @request.env["decidim.current_organization"] = organization
  end

  describe "helper methods" do
    describe "participatory_processes" do
      it "orders them by end_date" do
        unpublished = create(
          :participatory_process,
          :with_steps,
          :unpublished,
          organization: organization
        )

        last = create(
          :participatory_process,
          :with_steps,
          :published,
          organization: organization,
          end_date: nil
        )
        last.active_step.update_attribute(:end_date, nil)

        first = create(
          :participatory_process,
          :with_steps,
          :published,
          organization: organization,
          end_date: Time.current.advance(days: 10)
        )
        first.active_step.update_attribute(:end_date, Time.current.advance(days: 2))

        second = create(
          :participatory_process,
          :with_steps,
          :published,
          organization: organization,
          end_date: Time.current.advance(days: 20)
        )
        second.active_step.update_attribute(:end_date, Time.current.advance(days: 4))

        expect(controller.helpers.participatory_processes.count).to eq(3)
        expect(controller.helpers.participatory_processes).not_to include(unpublished)
        expect(controller.helpers.participatory_processes.first).to eq(first)
        expect(controller.helpers.participatory_processes.to_a[1]).to eq(second)
        expect(controller.helpers.participatory_processes.to_a.last).to eq(last)
      end
    end
  end
end

RSpec.shared_examples "with promoted participatory processes" do
  before do
    @request.env["decidim.current_organization"] = organization
  end
  describe "helper methods" do
    describe "promoted_participatory_processes" do
      it "orders them by active_step end_date" do
        unpublished = create(
          :participatory_process,
          :with_steps,
          :unpublished,
          :promoted,
          organization: organization
        )

        _unpromoted = create(
          :participatory_process,
          :with_steps,
          :unpublished,
          organization: organization
        )

        last = create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization
        )
        last.active_step.update_attribute(:end_date, nil)

        first = create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 10)
        )
        first.active_step.update_attribute(:end_date, Time.current.advance(days: 2))

        second = create(
          :participatory_process,
          :with_steps,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 8)
        )
        second.active_step.update_attribute(:end_date, Time.current.advance(days: 4))

        expect(controller.helpers.promoted_participatory_processes.count).to eq(3)
        expect(controller.helpers.promoted_participatory_processes).not_to include(unpublished)
        expect(controller.helpers.promoted_participatory_processes.first).to eq(first)
        expect(controller.helpers.promoted_participatory_processes.to_a[1]).to eq(second)
        expect(controller.helpers.promoted_participatory_processes.to_a.last).to eq(last)
      end
    end
  end
end

RSpec.shared_examples "with participatory processes and groups" do
  before do
    @request.env["decidim.current_organization"] = organization
  end

  let(:other_organization) { create(:organization) }

  describe "helper methods" do
    describe "collection" do
      it "includes a heterogeneous array of processes and groups" do
        published = create_list(
          :participatory_process,
          2,
          :published,
          organization: organization
        )

        _unpublished = create_list(
          :participatory_process,
          2,
          :unpublished,
          organization: organization
        )

        organization_groups = create_list(
          :participatory_process_group,
          2,
          organization: organization
        )

        _other_groups = create_list(
          :participatory_process_group,
          2,
          organization: other_organization
        )

        expect(controller.helpers.collection).to \
          contain_exactly(*published, *organization_groups)
      end
    end
  end
end
