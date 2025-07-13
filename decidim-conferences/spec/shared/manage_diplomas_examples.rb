# frozen_string_literal: true

shared_examples "manage diplomas" do
  let(:main_logo_filename) { "city.jpeg" }
  let(:main_logo_path) { Decidim::Dev.asset(main_logo_filename) }

  let(:signature_filename) { "city2.jpeg" }
  let(:signature_path) { Decidim::Dev.asset(signature_filename) }

  context "when diploma configuration not exists" do
    it "configure the diploma settings" do
      within "tr", text: translated(conference.title) do
        find("button[data-component='dropdown']").click
        click_on "Configure"
      end

      within_admin_sidebar_menu do
        click_on "Certificate of attendance"
      end

      dynamically_attach_file(:conference_main_logo, main_logo_path)
      dynamically_attach_file(:conference_signature, signature_path)

      within ".edit_conference_diploma" do
        fill_in_datepicker :conference_sign_date_date, with: 5.days.from_now.strftime("%d/%m/%Y")
        fill_in :conference_signature_name, with: "Signature name"

        click_on "Save"
      end

      expect(page).to have_admin_callout("successfully")
    end
  end

  context "when diploma configuration exists" do
    let!(:conference) { create(:conference, :diploma, organization:) }

    context "and a few registrations have been confirmed" do
      let!(:conference_registrations) { create_list(:conference_registration, 10, conference:) }

      context "and diplomas has not been sent" do
        before do
          within "tr", text: translated(conference.title) do
            find("button[data-component='dropdown']").click
            click_on "Configure"
          end

          within_admin_sidebar_menu do
            click_on "Certificate of attendance"
          end
        end

        it "can send the diplomas" do
          expect(page).to have_css("#send-diplomas")
          expect(page).to have_content("Send certificates of attendance")
        end

        it "is successfully created" do
          click_on "Send certificates of attendance"
          expect(page).to have_admin_callout("successfully")
        end
      end

      context "and diplomas already has been sent" do
        let!(:conference_registrations) { create_list(:conference_registration, 10, conference:) }

        before do
          conference.diploma_sent_at = Time.current
          conference.save
          conference.reload
        end

        it "cannot send the diplomas" do
          within "tr", text: translated(conference.title) do
            find("button[data-component='dropdown']").click
            click_on "Configure"
          end

          within_admin_sidebar_menu do
            click_on "Certificate of attendance"
          end

          expect(page).to have_css("#send-diplomas.disabled")
          expect(page).to have_content("Send certificates of attendance")
        end
      end
    end

    context "and registration has not been confirmed" do
      let!(:conference_registrations) { create_list(:conference_registration, 10, :unconfirmed, conference:) }

      it "cannot send the diplomas" do
        within "tr", text: translated(conference.title) do
          find("button[data-component='dropdown']").click
          click_on "Configure"
        end

        within_admin_sidebar_menu do
          click_on "Certificate of attendance"
        end

        expect(page).to have_no_css("#send-diplomas")
        expect(page).to have_content("Certificate of attendance")
      end
    end
  end
end
