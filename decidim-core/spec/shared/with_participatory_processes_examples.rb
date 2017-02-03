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
          :unpublished,
          organization: organization
        )

        last = create(
          :participatory_process,
          :published,
          organization: organization,
          end_date: nil
        )

        first = create(
          :participatory_process,
          :published,
          organization: organization,
          end_date: Time.current.advance(days: 10)
        )

        second = create(
          :participatory_process,
          :published,
          organization: organization,
          end_date: Time.current.advance(days: 20)
        )

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
      it "orders them by end_date" do
        unpublished = create(
          :participatory_process,
          :unpublished,
          :promoted,
          organization: organization
        )

        unpromoted = create(
          :participatory_process,
          :unpublished,
          organization: organization
        )

        last = create(
          :participatory_process,
          :published,
          :promoted,
          organization: organization,
          end_date: nil
        )

        first = create(
          :participatory_process,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 10)
        )

        second = create(
          :participatory_process,
          :published,
          :promoted,
          organization: organization,
          end_date: Time.current.advance(days: 20)
        )

        expect(controller.helpers.promoted_participatory_processes.count).to eq(3)
        expect(controller.helpers.promoted_participatory_processes).not_to include(unpublished)
        expect(controller.helpers.promoted_participatory_processes.first).to eq(first)
        expect(controller.helpers.promoted_participatory_processes.to_a[1]).to eq(second)
        expect(controller.helpers.promoted_participatory_processes.to_a.last).to eq(last)
      end
    end
  end
end
