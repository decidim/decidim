const getDismissedHelpers = () => (localStorage.getItem("dismissedHelpers") || "").split(",")

const addDismissedHelper = (id) => {
  const dismissedHelpers = getDismissedHelpers();

  if (!dismissedHelpers.includes(id)) {
    localStorage.setItem(
      "dismissedHelpers",
      [...dismissedHelpers, id].join(",")
    );
  }
};

const displayTip = (element) => {
  element.classList.add("is-tip")
  element.classList.remove("is-block")
}

const displayBlock = (element) => {
  element.classList.add("is-block")
  element.classList.remove("is-tip")
}

// eslint-disable-next-line require-jsdoc
export default function addFloatingHelp(element) {
  const { floatingHelp: id } = element.dataset
  const dismissedHelpers = getDismissedHelpers()

  if (dismissedHelpers.includes(id)) {
    displayTip(element)
  }

  addDismissedHelper(id)

  element.querySelector('[id*="tip"]').addEventListener("click", () => displayBlock(element))
  element.querySelector('[id*="block"]').addEventListener("click", () => displayTip(element))
}
