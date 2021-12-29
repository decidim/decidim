$(() => {
  const $content = $(".picker-content"),
      pickerMore = $content.data("picker-more"),
      pickerPath = $content.data("picker-path"),
      toggleNoProposals = () => {
        const showNoProposals = $("#proposals_list li:visible").length === 0
        $("#no_proposals").toggle(showNoProposals)
      }

  let jqxhr = null
  let filterBuffer = ""

  toggleNoProposals()

  $(".data_picker-modal-content").on("change keyup", "#proposals_filter", (event) => {
    const filter = event.target.value.toLowerCase()

    if (pickerMore) {
      if (filter.length < 3) {
        return
      }

      if (filter === filterBuffer) {
        return
      }

      if (jqxhr !== null) {
        jqxhr.abort()
      }

      $content.html("<div class='loading-spinner'></div>")
      jqxhr = $.get(`${pickerPath}?q=${filter}`, (data) => {
        filterBuffer = filter
        $content.html(data)
        jqxhr = null
        toggleNoProposals()

        if (typeof window.theDataPicker === "object" && window.theDataPicker.current !== null) {
          window.theDataPicker._handleCheckboxes($content);
          window.theDataPicker._handleLinks($content);
        }
      })
    } else {
      $("#proposals_list li").each((index, li) => {
        $(li).toggle(li.textContent.toLowerCase().indexOf(filter) > -1)
      })
      toggleNoProposals()
    }
  })
})
