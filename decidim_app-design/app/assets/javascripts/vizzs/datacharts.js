/* eslint-disable max-lines */
/* global areachart, renderLineCharts, renderRowCharts */

// NOTE: This file purpose is only to populate data for charts
let DATACHARTS = {}
$(() => {
  const chart = () => {
    // Generate fake data
    const mockData = () => {
      let arr = []

      for (let index = 0; index < 100; index += 1) {
        arr.push({
          "key": new Date(2015, 1, index + 15),
          "value": Math.floor(Math.random() * (500 - 200 + 1)) + 200
        })
      }

      return arr
    }

    return $(".areachart:visible").each((id, container) => {
      const $container = $(`#${container.id}`)

      areachart({
        container: $container.selector,
        data: mockData(),
        ...$container.data()
      });
    })
  }

  DATACHARTS["linechart-0"] = [
    {
      "key": "South Dakota",
      "value": [
        {
          "key": "2017-10-19T02:36:25-02:00",
          "value": 14
        },
        {
          "key": "2016-09-20T08:33:37-02:00",
          "value": 16
        },
        {
          "key": "2016-10-05T09:03:02-02:00",
          "value": 46
        },
        {
          "key": "2017-07-16T04:56:14-02:00",
          "value": 34
        },
        {
          "key": "2017-12-18T07:32:08-01:00",
          "value": 20
        },
        {
          "key": "2017-09-02T10:28:54-02:00",
          "value": 17
        },
        {
          "key": "2017-01-19T04:50:01-01:00",
          "value": 33
        },
        {
          "key": "2016-03-26T04:57:24-01:00",
          "value": 50
        },
        {
          "key": "2017-03-30T10:23:57-02:00",
          "value": 20
        }
      ]
    },
    {
      "key": "Minnesota",
      "value": [
        {
          "key": "2017-08-12T01:18:07-02:00",
          "value": 15
        },
        {
          "key": "2017-11-01T03:21:37-01:00",
          "value": 24
        },
        {
          "key": "2016-02-23T08:08:19-01:00",
          "value": 35
        },
        {
          "key": "2017-03-28T01:09:58-02:00",
          "value": 22
        },
        {
          "key": "2017-04-07T12:26:51-02:00",
          "value": 26
        },
        {
          "key": "2016-09-27T05:58:05-02:00",
          "value": 30
        },
        {
          "key": "2016-10-30T12:27:56-01:00",
          "value": 27
        },
        {
          "key": "2016-08-08T06:57:43-02:00",
          "value": 21
        },
        {
          "key": "2017-07-26T02:54:42-02:00",
          "value": 20
        }
      ]
    },
    {
      "key": "Illinois",
      "value": [
        {
          "key": "2017-06-05T03:33:07-02:00",
          "value": 45
        },
        {
          "key": "2016-07-07T04:25:07-02:00",
          "value": 31
        },
        {
          "key": "2017-01-07T12:57:38-01:00",
          "value": 49
        },
        {
          "key": "2017-05-16T01:03:17-02:00",
          "value": 17
        },
        {
          "key": "2017-11-12T04:35:23-01:00",
          "value": 15
        },
        {
          "key": "2016-08-05T03:15:50-02:00",
          "value": 40
        },
        {
          "key": "2016-07-01T08:56:02-02:00",
          "value": 18
        },
        {
          "key": "2017-01-02T06:23:32-01:00",
          "value": 28
        },
        {
          "key": "2017-02-17T11:44:14-01:00",
          "value": 43
        }
      ]
    }
  ]
  DATACHARTS["linechart-1"] = [
    {
      "key": "Illinois",
      "value": [
        {
          "key": "2017-08-11T08:35:03-02:00",
          "value": 40
        },
        {
          "key": "2016-07-07T08:43:38-02:00",
          "value": 36
        },
        {
          "key": "2017-06-29T09:27:17-02:00",
          "value": 41
        },
        {
          "key": "2017-09-19T08:11:45-02:00",
          "value": 19
        },
        {
          "key": "2016-05-27T05:54:32-02:00",
          "value": 30
        },
        {
          "key": "2016-10-14T04:54:44-02:00",
          "value": 34
        },
        {
          "key": "2016-02-22T08:17:49-01:00",
          "value": 24
        },
        {
          "key": "2017-02-21T01:51:27-01:00",
          "value": 13
        },
        {
          "key": "2016-08-23T01:22:05-02:00",
          "value": 36
        },
        {
          "key": "2016-07-14T05:22:37-02:00",
          "value": 28
        },
        {
          "key": "2017-01-17T01:52:51-01:00",
          "value": 17
        },
        {
          "key": "2016-09-12T12:37:35-02:00",
          "value": 45
        },
        {
          "key": "2016-04-17T11:02:06-02:00",
          "value": 17
        },
        {
          "key": "2016-06-25T02:47:42-02:00",
          "value": 47
        },
        {
          "key": "2016-12-27T07:40:36-01:00",
          "value": 33
        },
        {
          "key": "2017-04-19T01:33:33-02:00",
          "value": 13
        },
        {
          "key": "2016-10-31T05:03:57-01:00",
          "value": 29
        }
      ]
    },
    {
      "key": "Arkansas",
      "value": [
        {
          "key": "2017-12-11T11:42:34-01:00",
          "value": 16
        },
        {
          "key": "2017-11-18T06:37:43-01:00",
          "value": 29
        },
        {
          "key": "2016-11-09T05:11:40-01:00",
          "value": 49
        },
        {
          "key": "2016-02-11T11:50:13-01:00",
          "value": 41
        },
        {
          "key": "2017-12-21T04:28:01-01:00",
          "value": 39
        },
        {
          "key": "2016-12-30T03:09:03-01:00",
          "value": 31
        },
        {
          "key": "2016-06-18T08:32:54-02:00",
          "value": 24
        },
        {
          "key": "2017-09-09T03:34:20-02:00",
          "value": 39
        },
        {
          "key": "2017-08-07T01:36:42-02:00",
          "value": 19
        },
        {
          "key": "2017-01-05T02:27:57-01:00",
          "value": 28
        },
        {
          "key": "2017-01-03T09:46:06-01:00",
          "value": 42
        },
        {
          "key": "2016-12-14T02:58:45-01:00",
          "value": 17
        },
        {
          "key": "2017-05-23T08:25:44-02:00",
          "value": 14
        },
        {
          "key": "2017-07-10T10:13:39-02:00",
          "value": 40
        },
        {
          "key": "2016-02-21T08:58:57-01:00",
          "value": 44
        },
        {
          "key": "2016-08-16T02:59:38-02:00",
          "value": 12
        },
        {
          "key": "2016-07-22T11:08:05-02:00",
          "value": 48
        },
        {
          "key": "2016-12-03T10:48:28-01:00",
          "value": 11
        },
        {
          "key": "2017-08-03T05:33:26-02:00",
          "value": 23
        }
      ]
    },
    {
      "key": "New Jersey",
      "value": [
        {
          "key": "2016-06-17T09:12:39-02:00",
          "value": 14
        },
        {
          "key": "2016-06-26T09:28:18-02:00",
          "value": 28
        },
        {
          "key": "2017-04-02T04:40:00-02:00",
          "value": 16
        },
        {
          "key": "2016-02-23T10:24:10-01:00",
          "value": 18
        },
        {
          "key": "2017-07-29T08:35:08-02:00",
          "value": 21
        },
        {
          "key": "2016-12-30T10:43:56-01:00",
          "value": 16
        },
        {
          "key": "2016-10-08T01:10:15-02:00",
          "value": 21
        },
        {
          "key": "2016-11-24T01:58:51-01:00",
          "value": 17
        },
        {
          "key": "2016-02-03T09:56:07-01:00",
          "value": 44
        },
        {
          "key": "2017-01-30T08:34:56-01:00",
          "value": 42
        },
        {
          "key": "2017-06-13T03:49:10-02:00",
          "value": 24
        },
        {
          "key": "2016-02-04T12:09:31-01:00",
          "value": 45
        }
      ]
    }
  ]
  DATACHARTS["linechart-2"] = [
    {
      "key": "Puerto Rico",
      "value": [
        {
          "key": "2018-01-20T05:53:35-01:00",
          "value": 37
        },
        {
          "key": "2016-05-09T11:47:58-02:00",
          "value": 13
        },
        {
          "key": "2016-04-07T11:13:27-02:00",
          "value": 44
        },
        {
          "key": "2016-11-15T10:17:25-01:00",
          "value": 23
        },
        {
          "key": "2016-04-03T08:39:40-02:00",
          "value": 31
        },
        {
          "key": "2018-01-06T05:42:30-01:00",
          "value": 14
        },
        {
          "key": "2016-07-27T09:44:24-02:00",
          "value": 33
        },
        {
          "key": "2017-04-18T09:23:36-02:00",
          "value": 38
        },
        {
          "key": "2017-01-12T04:10:08-01:00",
          "value": 13
        },
        {
          "key": "2016-06-07T01:46:35-02:00",
          "value": 29
        },
        {
          "key": "2017-05-04T08:45:03-02:00",
          "value": 13
        },
        {
          "key": "2016-05-29T09:30:51-02:00",
          "value": 19
        },
        {
          "key": "2017-09-11T04:46:34-02:00",
          "value": 40
        },
        {
          "key": "2017-07-27T07:43:02-02:00",
          "value": 20
        },
        {
          "key": "2016-06-25T03:25:06-02:00",
          "value": 13
        },
        {
          "key": "2016-08-03T06:37:40-02:00",
          "value": 23
        },
        {
          "key": "2018-01-24T04:12:00-01:00",
          "value": 26
        },
        {
          "key": "2017-01-24T02:37:44-01:00",
          "value": 28
        },
        {
          "key": "2017-04-26T08:12:23-02:00",
          "value": 30
        }
      ]
    },
    {
      "key": "Idaho",
      "value": [
        {
          "key": "2016-12-28T04:14:10-01:00",
          "value": 20
        },
        {
          "key": "2017-09-04T01:01:34-02:00",
          "value": 21
        },
        {
          "key": "2016-07-05T12:56:57-02:00",
          "value": 46
        },
        {
          "key": "2016-12-28T06:48:59-01:00",
          "value": 28
        },
        {
          "key": "2017-02-26T03:33:35-01:00",
          "value": 12
        },
        {
          "key": "2016-10-13T10:03:58-02:00",
          "value": 18
        },
        {
          "key": "2016-04-30T03:03:23-02:00",
          "value": 26
        },
        {
          "key": "2016-10-05T02:44:22-02:00",
          "value": 24
        },
        {
          "key": "2017-11-29T02:15:16-01:00",
          "value": 19
        },
        {
          "key": "2017-04-16T08:24:44-02:00",
          "value": 21
        },
        {
          "key": "2016-12-13T08:31:49-01:00",
          "value": 43
        },
        {
          "key": "2016-12-28T11:02:12-01:00",
          "value": 19
        },
        {
          "key": "2017-10-03T08:02:58-02:00",
          "value": 33
        }
      ]
    },
    {
      "key": "Kentucky",
      "value": [
        {
          "key": "2016-12-06T03:05:22-01:00",
          "value": 33
        },
        {
          "key": "2016-05-24T11:10:03-02:00",
          "value": 16
        },
        {
          "key": "2016-11-07T08:56:40-01:00",
          "value": 32
        },
        {
          "key": "2017-09-21T05:24:07-02:00",
          "value": 44
        },
        {
          "key": "2017-11-19T03:24:38-01:00",
          "value": 27
        },
        {
          "key": "2017-11-07T11:40:04-01:00",
          "value": 38
        },
        {
          "key": "2017-09-28T02:20:56-02:00",
          "value": 16
        },
        {
          "key": "2017-02-12T01:08:44-01:00",
          "value": 30
        },
        {
          "key": "2017-09-08T09:33:58-02:00",
          "value": 20
        },
        {
          "key": "2017-03-01T05:00:43-01:00",
          "value": 47
        }
      ]
    }
  ]
  DATACHARTS["rowchart-0"] = [
    {
      "key": "Honduras",
      "value": [
        {
          "key": "banana",
          "value": 41
        },
        {
          "key": "lemon",
          "value": 35
        },
        {
          "key": "pear",
          "value": 32
        }
      ]
    },
    {
      "key": "Romania",
      "value": [
        {
          "key": "pear",
          "value": 24
        },
        {
          "key": "lemon",
          "value": 45
        },
        {
          "key": "banana",
          "value": 27
        }
      ]
    },
    {
      "key": "Central African Republic",
      "value": [
        {
          "key": "pear",
          "value": 14
        },
        {
          "key": "banana",
          "value": 10
        }
      ]
    },
    {
      "key": "Angola",
      "value": [
        {
          "key": "lemon",
          "value": 23
        },
        {
          "key": "banana",
          "value": 31
        },
        {
          "key": "pear",
          "value": 23
        }
      ]
    },
    {
      "key": "Malta",
      "value": [
        {
          "key": "lemon",
          "value": 20
        },
        {
          "key": "pear",
          "value": 46
        }
      ]
    },
    {
      "key": "Oman",
      "value": [
        {
          "key": "banana",
          "value": 37
        },
        {
          "key": "pear",
          "value": 17
        }
      ]
    },
    {
      "key": "Heard and McDonald Islands",
      "value": [
        {
          "key": "banana",
          "value": 21
        }
      ]
    },
    {
      "key": "Morocco",
      "value": [
        {
          "key": "lemon",
          "value": 29
        },
        {
          "key": "banana",
          "value": 43
        }
      ]
    },
    {
      "key": "Syria",
      "value": [
        {
          "key": "lemon",
          "value": 10
        }
      ]
    },
    {
      "key": "Viet Nam",
      "value": [
        {
          "key": "lemon",
          "value": 13
        },
        {
          "key": "banana",
          "value": 23
        },
        {
          "key": "pear",
          "value": 24
        }
      ]
    }
  ]
  DATACHARTS["rowchart-1"] = [
    {
      "key": "Elfrida Montieth Street",
      "value": [
        {
          "key": "pear",
          "value": 44
        },
        {
          "key": "banana",
          "value": 36
        },
        {
          "key": "lemon",
          "value": 40
        }
      ]
    },
    {
      "key": "Hailesboro Freeman Street",
      "value": [
        {
          "key": "pear",
          "value": 45
        },
        {
          "key": "banana",
          "value": 26
        },
        {
          "key": "lemon",
          "value": 50
        }
      ]
    },
    {
      "key": "Farmington Seeley Street",
      "value": [
        {
          "key": "pear",
          "value": 39
        },
        {
          "key": "banana",
          "value": 16
        },
        {
          "key": "lemon",
          "value": 25
        }
      ]
    },
    {
      "key": "Cazadero Seigel Street",
      "value": [
        {
          "key": "pear",
          "value": 29
        },
        {
          "key": "banana",
          "value": 41
        },
        {
          "key": "lemon",
          "value": 26
        }
      ]
    },
    {
      "key": "Interlochen Cypress Court",
      "value": [
        {
          "key": "pear",
          "value": 15
        },
        {
          "key": "banana",
          "value": 34
        },
        {
          "key": "lemon",
          "value": 11
        }
      ]
    },
    {
      "key": "Murillo Union Avenue",
      "value": [
        {
          "key": "pear",
          "value": 24
        },
        {
          "key": "banana",
          "value": 12
        },
        {
          "key": "lemon",
          "value": 39
        }
      ]
    },
    {
      "key": "Turpin Suydam Street",
      "value": [
        {
          "key": "pear",
          "value": 13
        },
        {
          "key": "banana",
          "value": 43
        },
        {
          "key": "lemon",
          "value": 13
        }
      ]
    },
    {
      "key": "Gerber Caton Place",
      "value": [
        {
          "key": "pear",
          "value": 10
        },
        {
          "key": "banana",
          "value": 27
        },
        {
          "key": "lemon",
          "value": 32
        }
      ]
    }
  ]
  DATACHARTS["rowchart-2"] = [
    {
      "key": "anim sunt incididunt enim nisi veniam tempor labore culpa ullamco ex tempor elit dolor laboris",
      "value": [
        {
          "key": "pear",
          "value": 11
        },
        {
          "key": "banana",
          "value": 43
        },
        {
          "key": "lemon",
          "value": 36
        }
      ]
    },
    {
      "key": "pariatur cillum labore laboris eiusmod qui sunt eiusmod nisi irure tempor culpa officia velit elit",
      "value": [
        {
          "key": "pear",
          "value": 19
        },
        {
          "key": "banana",
          "value": 45
        },
        {
          "key": "lemon",
          "value": 11
        }
      ]
    },
    {
      "key": "labore proident est irure magna exercitation in anim Lorem cillum amet esse anim quis magna",
      "value": [
        {
          "key": "pear",
          "value": 15
        },
        {
          "key": "banana",
          "value": 25
        },
        {
          "key": "lemon",
          "value": 46
        }
      ]
    },
    {
      "key": "Lorem adipisicing amet eu sint magna deserunt ad nisi officia irure aliqua nulla voluptate reprehenderit",
      "value": [
        {
          "key": "pear",
          "value": 44
        },
        {
          "key": "banana",
          "value": 27
        },
        {
          "key": "lemon",
          "value": 31
        }
      ]
    },
    {
      "key": "aliqua velit esse minim velit pariatur consequat amet amet deserunt sunt quis ea ut mollit",
      "value": [
        {
          "key": "pear",
          "value": 42
        },
        {
          "key": "banana",
          "value": 20
        },
        {
          "key": "lemon",
          "value": 24
        }
      ]
    },
    {
      "key": "ex ipsum ex esse ut officia irure laborum consectetur irure enim irure deserunt amet exercitation",
      "value": [
        {
          "key": "pear",
          "value": 14
        },
        {
          "key": "banana",
          "value": 40
        },
        {
          "key": "lemon",
          "value": 24
        }
      ]
    },
    {
      "key": "cillum velit amet nostrud veniam eu quis do veniam Lorem Lorem proident cillum elit nostrud",
      "value": [
        {
          "key": "pear",
          "value": 11
        },
        {
          "key": "banana",
          "value": 10
        },
        {
          "key": "lemon",
          "value": 39
        }
      ]
    },
    {
      "key": "enim ex tempor sit nulla cupidatat commodo nostrud anim labore enim in dolor ullamco cupidatat",
      "value": [
        {
          "key": "pear",
          "value": 11
        },
        {
          "key": "banana",
          "value": 18
        },
        {
          "key": "lemon",
          "value": 28
        }
      ]
    },
    {
      "key": "amet eu sint labore cupidatat sunt dolor aute et elit laboris officia non ea nulla",
      "value": [
        {
          "key": "pear",
          "value": 14
        },
        {
          "key": "banana",
          "value": 26
        },
        {
          "key": "lemon",
          "value": 40
        }
      ]
    }
  ]
  DATACHARTS["rowchart-3"] = [
    {
      "key": "Isopop Pickett",
      "value": [
        {
          "key": "pear",
          "value": 48
        },
        {
          "key": "banana",
          "value": 38
        },
        {
          "key": "lemon",
          "value": 20
        },
        {
          "key": "apple",
          "value": 15
        },
        {
          "key": "raspberry",
          "value": 41
        },
        {
          "key": "pinneaple",
          "value": 12
        },
        {
          "key": "blueberry",
          "value": 41
        },
        {
          "key": "watermelon",
          "value": 26
        },
        {
          "key": "orange",
          "value": 34
        }
      ]
    },
    {
      "key": "Obones Leach",
      "value": [
        {
          "key": "pear",
          "value": 44
        },
        {
          "key": "banana",
          "value": 49
        },
        {
          "key": "lemon",
          "value": 34
        },
        {
          "key": "apple",
          "value": 25
        },
        {
          "key": "raspberry",
          "value": 41
        },
        {
          "key": "pinneaple",
          "value": 18
        },
        {
          "key": "blueberry",
          "value": 47
        },
        {
          "key": "watermelon",
          "value": 14
        },
        {
          "key": "orange",
          "value": 44
        }
      ]
    },
    {
      "key": "Colaire Carter",
      "value": [
        {
          "key": "pear",
          "value": 49
        },
        {
          "key": "banana",
          "value": 44
        },
        {
          "key": "lemon",
          "value": 31
        },
        {
          "key": "apple",
          "value": 20
        },
        {
          "key": "raspberry",
          "value": 32
        },
        {
          "key": "pinneaple",
          "value": 43
        },
        {
          "key": "blueberry",
          "value": 39
        },
        {
          "key": "watermelon",
          "value": 27
        },
        {
          "key": "orange",
          "value": 38
        }
      ]
    },
    {
      "key": "Signity Levy",
      "value": [
        {
          "key": "pear",
          "value": 14
        },
        {
          "key": "banana",
          "value": 20
        },
        {
          "key": "lemon",
          "value": 35
        },
        {
          "key": "apple",
          "value": 20
        },
        {
          "key": "raspberry",
          "value": 26
        },
        {
          "key": "pinneaple",
          "value": 15
        },
        {
          "key": "blueberry",
          "value": 20
        },
        {
          "key": "watermelon",
          "value": 15
        },
        {
          "key": "orange",
          "value": 43
        }
      ]
    },
    {
      "key": "Opticon Doyle",
      "value": [
        {
          "key": "pear",
          "value": 14
        },
        {
          "key": "banana",
          "value": 39
        },
        {
          "key": "lemon",
          "value": 38
        },
        {
          "key": "apple",
          "value": 34
        },
        {
          "key": "raspberry",
          "value": 33
        },
        {
          "key": "pinneaple",
          "value": 43
        },
        {
          "key": "blueberry",
          "value": 42
        },
        {
          "key": "watermelon",
          "value": 11
        },
        {
          "key": "orange",
          "value": 49
        }
      ]
    },
    {
      "key": "Otherway Dillard",
      "value": [
        {
          "key": "pear",
          "value": 48
        },
        {
          "key": "banana",
          "value": 39
        },
        {
          "key": "lemon",
          "value": 36
        },
        {
          "key": "apple",
          "value": 34
        },
        {
          "key": "raspberry",
          "value": 50
        },
        {
          "key": "pinneaple",
          "value": 22
        },
        {
          "key": "blueberry",
          "value": 18
        },
        {
          "key": "watermelon",
          "value": 22
        },
        {
          "key": "orange",
          "value": 29
        }
      ]
    },
    {
      "key": "Mantrix Duke",
      "value": [
        {
          "key": "pear",
          "value": 16
        },
        {
          "key": "banana",
          "value": 32
        },
        {
          "key": "lemon",
          "value": 43
        },
        {
          "key": "apple",
          "value": 10
        },
        {
          "key": "raspberry",
          "value": 20
        },
        {
          "key": "pinneaple",
          "value": 13
        },
        {
          "key": "blueberry",
          "value": 16
        },
        {
          "key": "watermelon",
          "value": 40
        },
        {
          "key": "orange",
          "value": 31
        }
      ]
    },
    {
      "key": "Mangelica Obrien",
      "value": [
        {
          "key": "pear",
          "value": 22
        },
        {
          "key": "banana",
          "value": 44
        },
        {
          "key": "lemon",
          "value": 16
        },
        {
          "key": "apple",
          "value": 49
        },
        {
          "key": "raspberry",
          "value": 15
        },
        {
          "key": "pinneaple",
          "value": 50
        },
        {
          "key": "blueberry",
          "value": 24
        },
        {
          "key": "watermelon",
          "value": 44
        },
        {
          "key": "orange",
          "value": 45
        }
      ]
    },
    {
      "key": "Bytrex Kelly",
      "value": [
        {
          "key": "pear",
          "value": 20
        },
        {
          "key": "banana",
          "value": 16
        },
        {
          "key": "lemon",
          "value": 48
        },
        {
          "key": "apple",
          "value": 21
        },
        {
          "key": "raspberry",
          "value": 22
        },
        {
          "key": "pinneaple",
          "value": 26
        },
        {
          "key": "blueberry",
          "value": 29
        },
        {
          "key": "watermelon",
          "value": 27
        },
        {
          "key": "orange",
          "value": 31
        }
      ]
    },
    {
      "key": "Ecosys Taylor",
      "value": [
        {
          "key": "pear",
          "value": 31
        },
        {
          "key": "banana",
          "value": 10
        },
        {
          "key": "lemon",
          "value": 50
        },
        {
          "key": "apple",
          "value": 50
        },
        {
          "key": "raspberry",
          "value": 35
        },
        {
          "key": "pinneaple",
          "value": 31
        },
        {
          "key": "blueberry",
          "value": 42
        },
        {
          "key": "watermelon",
          "value": 37
        },
        {
          "key": "orange",
          "value": 31
        }
      ]
    }
  ]

  chart()
  renderLineCharts()
  renderRowCharts()
  $(document).on("change.zf.tabs down.zf.accordion", () => {
    chart()
    renderLineCharts()
    renderRowCharts()
  });
});
