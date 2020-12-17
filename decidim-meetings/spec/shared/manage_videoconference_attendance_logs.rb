# frozen_string_literal: true

def visit_meeting_videoconference_attendance_logs_page
  within find("tr", text: translated(meeting.title)) do
    page.click_link "Attendance"
  end
end

shared_examples "manage videoconference attendance logs" do
  let!(:meeting) { create(:meeting, embedded_videoconference: true, scope: scope, services: [], component: current_component) }
  let!(:attendance_logs) { create_list(:videoconference_attendance_log, 10, meeting: meeting) }

  describe "see attendance logs list" do
    it "shows attendance logs" do
      visit_meeting_videoconference_attendance_logs_page

      expect(page).to have_content("Join", count: attendance_logs.count { |log| log.event == "join" })
    end
  end
end
