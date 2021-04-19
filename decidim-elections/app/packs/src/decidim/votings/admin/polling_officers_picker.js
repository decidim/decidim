$(() => {
  const $content = $(".picker-content"),
      pickerMore = $content.data("picker-more"),
      pickerPath = $content.data("picker-path"),
      toggleNoPollingOfficers = () => {
        const showNoPollingOfficers = $("#polling_officers_list li:visible").length === 0
        $("#no_polling_officers").toggle(showNoPollingOfficers)
      }

  let jqxhr = null

  toggleNoPollingOfficers()

  $(".data_picker-modal-content").on("change keyup", "#polling_officers_filter", (event) => {
    const filter = event.target.value.toLowerCase()

    if (pickerMore) {
      if (jqxhr !== null) {
        jqxhr.abort()
      }

      $content.html("<div class='loading-spinner'></div>")
      jqxhr = $.get(`${pickerPath}?q=${filter}`, (data) => {
        $content.html(data)
        jqxhr = null
        toggleNoPollingOfficers()
      })
    } else {
      $("#polling_officers_list li").each((index, li) => {
        $(li).toggle(li.textContent.toLowerCase().includes(filter))
      })
      toggleNoPollingOfficers()
    }
  })
})
