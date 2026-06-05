const escapeQuotes = (text) => {
  if (!text) {
    return "";
  }

  return text.replace(/"/g, "&quot;");
}

export const escapeHtml = (text) => {
  if (!text) {
    return "";
  }

  const el = document.createElement("div");
  el.appendChild(document.createTextNode(text));
  return escapeQuotes(el.innerHTML);
}
