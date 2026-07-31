const getRelativeTime = (date) => {
  const diffSeconds = Math.round((date.getTime() - Date.now()) / 1000)

  const absSeconds = Math.abs(diffSeconds)

  if (absSeconds < 60) {
    return [diffSeconds, "second"]
  }

  if (absSeconds < 3600) {
    return [Math.round(diffSeconds / 60), "minute"]
  }

  if (absSeconds < 86400) {
    return [Math.round(diffSeconds / 3600), "hour"]
  }

  if (absSeconds < 2592000) {
    return [Math.round(diffSeconds / 86400), "day"]
  }

  if (absSeconds < 31536000) {
    return [Math.round(diffSeconds / 2592000), "month"]
  }

  return [Math.round(diffSeconds / 31536000), "year"]
}

const updateTimeAgoElements = () => {
  const locale = document.documentElement.lang || "en"

  const formatter = new Intl.RelativeTimeFormat(locale, {
    numeric: "auto"
  })

  document
    .querySelectorAll("time[data-relative-time]")
    .forEach((element) => {
      const date = new Date(element.getAttribute("datetime"))

      if (Number.isNaN(date.getTime())) {
        return
      }

      const [value, unit] = getRelativeTime(date)

      element.textContent = formatter.format(value, unit)
    })
}

let refreshInterval

const initializeTimeAgoRefresh = () => {
  updateTimeAgoElements()

  if (!refreshInterval) {
    refreshInterval = window.setInterval(updateTimeAgoElements, 60000)
  }
}

export default initializeTimeAgoRefresh
