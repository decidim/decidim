import AutoComplete from "src/decidim/autocomplete";

/**
 * Sends a query to the API and resolves the resulting data in the returned
 * promise object.
 *
 * @param {String} query The root query to be sent to the API e.g.
 *   "decidim { version }".
 * @returns {Promise} Promise resolving the data returned by the API.
 */
const apiRequest = (query) => {
  return new Promise((resolve) => {
    fetch("/api", {
      method: "post",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ query: `{ ${query} }` })
    }).then((response) => response.json()).then((queryResponse) => {
      resolve(queryResponse.data);
    });
  })
};

/**
 * Resolves the different root fields for listing different participatory spaces
 * available in the instance. Returns all LIST kind root fields that list
 * records implemeting the ParticipatorySpaceInterface.
 *
 * @returns {Promise} A promise resolving the root fields for querying different
 *   participatory spaces.
 */
const resolveParticipatorySpaceTypes = () => {
  const schemaQuery = `
    __schema {
      queryType {
        fields {
          name
          type {
            kind
            ofType {
              ofType {
                interfaces {
                  name
                }
                kind
              }
            }
          }
        }
      }
    }
  `;

  /**
   * Resolves whether the provided field returned by the API is a participatory
   * space root field or not.
   *
   * @param {Object} field The field object returned by the API.
   * @returns {Boolean} True if the provided field is a participatory space
   *   field or false when it is not.
   */
  const isParticipatorySpaceField = (field) => {
    if (field.type.kind !== "LIST") {
      return false;
    }
    if (!field.type.ofType || !field.type.ofType.ofType || !field.type.ofType.ofType.interfaces) {
      return false;
    }
    if (!field.type.ofType.ofType.interfaces.some((interf) => interf.name === "ParticipatorySpaceInterface")) {
      return false;
    }

    return true;
  }

  return new Promise((resolve) => {
    apiRequest(schemaQuery).then((result) => {
      const types = [];

      for (const field of result.__schema.queryType.fields) {
        if (isParticipatorySpaceField(field)) {
          types.push(field.name);
        }
      }

      resolve(types);
    });
  });
};

/**
 * Resovles the different participatory space root queries and sends an API
 * request for each of them to resolve the list of available spaces of each
 * type.
 *
 * An example array resolved by the promise object looks as follows:
 * [
 *   {
 *     type: "participatory_processes",
 *     name: "Participatory processes",
 *     list: [
 *       { id: 1, title: "Foo" },
 *       { id: 2, title: "Bar" },
 *     ]
 *   },
 *   {
 *     type: "assemblies",
 *     name: "Assemblies",
 *     list: [
 *       { id: 1, title: "Foo" },
 *       { id: 2, title: "Bar" },
 *     ]
 *   }
 * ]
 *
 * @returns {Promise} A promise resolving the different participatory spaces as
 *   explained above.
 */
const getParticipatorySpaces = () => {
  const currentLocale = document.documentElement.lang;
  const spaceQuery = `
    id
    title { translation(locale: "${currentLocale}") }
    manifest {
      name
      humanName {
        plural { translation(locale: "${currentLocale}") }
      }
    }
  `;

  return new Promise((resolve) => {
    resolveParticipatorySpaceTypes().then((types) => {
      // To make the request faster, combine all spaces into the same query
      const spaceQueries = types.map((type) => `${type} { ${spaceQuery} }`);

      apiRequest(spaceQueries.join("\n\n")).then((spacesData) => {
        const spacesList = [];

        for (const type of types) {
          if (spacesData[type].length > 0) {
            spacesList.push({
              type: spacesData[type][0].manifest.name,
              name: spacesData[type][0].manifest.humanName.plural.translation,
              list: spacesData[type].map((space) => {
                return {
                  id: parseInt(space.id, 10),
                  title: space.title.translation
                };
              })
            })
          }
        }

        resolve(spacesList);
      });
    });
  })
}

/**
 * Creates an autocomplete input for the given search input element.
 *
 * @param {HTMLElement} searchInput The element to create the autocomplete for.
 * @param {Array} spaces An array of the available spaces as resolved by the
 *   `getParticipatorySpaces` method.
 * @param {Number} inputIndex The index of the autocomplete input on the page.
 * @returns {AutoComplete} The initiated AutoComplete instance.
 */
const createAutocomplete = (searchInput, spaces, inputIndex) => {

  /**
   * Data source method which provides the results for the autocomplete element.
   *
   * @param {String} query The query which is used to find the matching records.
   * @param {Function} callback A callback function that is called with the
   *   matching results array.
   * @returns {void}
   */
  const dataSource = (query, callback) => {
    const regexp = new RegExp(query, "i");
    const results = [];

    for (const currentSpace of spaces) {
      for (const space of currentSpace.list) {
        if (regexp.test(space.title)) {
          results.push({
            value: `${currentSpace.type}(${space.id})`,
            label: `${currentSpace.name} - ${space.title}`
          });
        }
      }
    }

    callback(results);
  };

  /**
   * Resolves the correct selected value for the autocomplete based on the query
   * argument which consists of the participatory space type and its ID.
   *
   * @param {String} originalValue The original value provided in the query
   *   arguments.
   * @returns {Object|null} Returns the matching value object or null in case
   *   no matching object was found.
   */
  const resolveSelectedValue = (originalValue) => {
    if (!originalValue) {
      return null;
    }

    const valueMatches = originalValue.match(/([a-z_]+)\(([0-9]+)\)/);
    if (!valueMatches) {
      return null;
    }

    const valueType = valueMatches[1];
    const valueId = parseInt(valueMatches[2], 10);
    for (const currentSpace of spaces) {
      if (currentSpace.type === valueType) {
        const space = currentSpace.list.find((item) => item.id === valueId);
        if (space) {
          return {
            value: `${currentSpace.type}(${space.id})`,
            label: `${currentSpace.name} - ${space.title}`
          };
        }
      }
    }

    return null;
  }

  let selected = null;
  const selectedValue = resolveSelectedValue(searchInput.dataset.selected);
  if (selectedValue) {
    selected = { key: "label", value: selectedValue };
  }

  const ac = new AutoComplete(searchInput, {
    name: searchInput.getAttribute("name"),
    placeholder: searchInput.getAttribute("placeholder"),
    mode: "sticky",
    threshold: 3,
    dataMatchKeys: ["label"],
    selected,
    dataSource
  });
  searchInput.name = `participatory_space_search_${inputIndex}`;

  return ac;
}

document.addEventListener("DOMContentLoaded", () => {
  const searchElements = document.querySelectorAll("input.participatory-space-search")
  if (searchElements.length < 1) {
    return;
  }

  getParticipatorySpaces().then((spaces) => {
    let index = 0;
    for (const searchInput of searchElements) {
      createAutocomplete(searchInput, spaces, index);
      index += 1;
    }
  });
});
