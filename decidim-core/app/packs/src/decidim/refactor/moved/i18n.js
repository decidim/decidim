/**
 * Gets the configured messages for Decidim. The configuration is passed from
 * the view to the JS within the layout template.
 *
 * @param {String | null} key The top-level key to fetch from the messages
 *   object or `null` to fetch all messages.
 * @returns {Object} The messages object
 */
export const getMessages = (key = null) => {
  const allMessages = window.Decidim.config.get("messages");
  if (key === null) {
    return allMessages;
  }
  let messages = allMessages;
  key.split(".").forEach((part) => (messages = messages[part] || {}));
  return messages;
};

/**
 * Turns a deep messages object into a dictionary object with a single level and
 * the keys separated with a dot.
 *
 * @param {Object} messages The messages object
 * @param {String | null} prefix Prefix for the messages on recursive calls
 * @returns {Object} The converted dictionary object
 */
export const createDictionary = (messages, prefix = "") => {
  let final = {};
  Object.keys(messages).forEach((key) => {
    if (typeof messages[key] === "object") {
      final = { ...final, ...createDictionary(messages[key], `${prefix}${key}.`) };
    } else if (key === "") {
      final[prefix?.replace(/\.$/, "") || ""] = messages[key];
    } else {
      final[`${prefix}${key}`] = messages[key];
    }
  });

  return final;
};

/**
 * Creates a dictionary object from the top-level messages object with the
 * provided key.
 *
 * @param {String | null} key The top-level message key to create the dictionary
 *   for
 * @returns {Object} The dictionary object
 */
export const getDictionary = (key) => {
  return createDictionary(getMessages(key));
}
