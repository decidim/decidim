$(() => {
  ((exports) => {
    const $form = $(".edit_meeting, .new_meeting");

    if ($form.length > 0) {
      const $meetingOpenType = $form.find("#meeting_open_type");
      const $meetingOpenTypeOther = $form.find("#meeting_open_type_other");

      const $meetingPublicType = $form.find("#meeting_public_type");
      const $meetingPublicTypeOther = $form.find("#meeting_public_type_other");

      const $meetingTransparentType = $form.find("#meeting_transparent_type");
      const $meetingTransparentTypeOther = $form.find("#meeting_transparent_type_other");

      const toggleDependsOnSelect = ($target, $showDiv) => {
        const value = $target.val();
        $showDiv.hide();
        if (value === "other") {
          $showDiv.show();
        }
      };

      $meetingOpenType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingOpenTypeOther);
      });

      $meetingPublicType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingPublicTypeOther);
      });

      $meetingTransparentType.on("change", (ev) => {
        const $target = $(ev.target);
        toggleDependsOnSelect($target, $meetingTransparentTypeOther);
      });


      toggleDependsOnSelect($meetingOpenType, $meetingOpenTypeOther);
      toggleDependsOnSelect($meetingPublicType, $meetingPublicTypeOther);
      toggleDependsOnSelect($meetingTransparentType, $meetingTransparentTypeOther);

    }


  })(window);
});
