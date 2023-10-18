# frozen_string_literal: true

shared_examples "process card with metadata" do |metadata_class:|
  context "with start and end date" do
    let(:model) { create(:participatory_process, start_date:, end_date:) }

    context "when process has started but is not finished" do
      let(:start_date) { Date.current }
      let(:end_date) { 2.months.from_now }

      it "renders the time remaining" do
        expect(subject).to have_css(".#{metadata_class} span", text: "2 months remaining")
      end
    end

    context "when process has not started" do
      let(:start_date) { 1.month.from_now }
      let(:end_date) { 2.months.from_now }

      it "renders the process has not started" do
        expect(subject).to have_css(".#{metadata_class} span", text: "Not started yet")
      end
    end

    context "when process has finished" do
      let(:start_date) { 3.months.ago }
      let(:end_date) { 2.months.ago }

      it "renders the process has finished with date" do
        expect(subject).to have_css(".#{metadata_class} span", text: "Finished: #{I18n.l(end_date.to_date, format: :decidim_short)}")
      end
    end
  end

  context "with steps" do
    let(:model) { create(:participatory_process, :with_steps) }

    it "renders the active step name" do
      expect(subject).to have_css(".#{metadata_class} span", text: translated(model.active_step.title))
    end
  end
end
