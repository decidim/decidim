import Papa from 'papaparse';

$(() => {
  const $processButton = $("#process_census");
  const censusFileInput = document.getElementById("dataset_file");
  $processButton.on("click", (event) => {
    event.preventDefault();
  
    if (censusFileInput.files.length > 0) {
      const censusFile = censusFileInput.files[0];
      // $processButton.toggleClass("disabled");
      
      parseAndProcess(censusFile);
    }
  });
});

const parseAndProcess = (censusFile) => {
  let rowCount = 0;
  const chunkSize = 10240; // 10kb
  const fileSize = censusFile.size;
  console.log("file:", censusFile);
  Papa.parse(censusFile, {
    header: true,
    worker: true,
    skipEmptyLines: true,
    chunkSize: chunkSize,
    chunk: (chunk) => {
      console.log("chunkSize:", chunkSize);
      console.log("chunk.meta:", chunk.meta);
      console.log("chunk.size:", chunk.data.length);
      const isLast = fileSize == chunk.meta.cursor;
      console.log("isLast:", isLast);
      const isFirst = chunk.meta.cursor <= chunkSize;
      console.log("isFirst:", isFirst);
      rowCount += chunk.data.length;
      processChunk(chunk.data, isFirst, isLast, rowCount);
    },
    complete: () => {
      // notifyFinished(rowCount);
    },
    error: (error) => {
      console.log("error", error);
    }
  });
}

const processChunk = async (rows, isFirst, isLast, rowCount) => {
  if (isFirst) {
    console.log("before createDataset");
    await createDataset();
    console.log("after createDataset");
  }
  
  console.log("before generateData");
  await generateData(rows);
  console.log("after generateData");

  if (isLast) {
    console.log("before notifyFinished");
    await notifyFinished(rowCount);
    console.log("after notifyFinished");
  }
}

const createDataset = () => {
  var request = new XMLHttpRequest();
  request.open('POST', '/admin/votings/excepturi-at/census/start_bulk_import', false);
  request.setRequestHeader("X-CSRF-Token", $("meta[name=csrf-token]").attr("content"))
  request.send(null);

  console.log("createDataset response:", request.responseText);
  // return $.ajax({
  //   method: "POST",
  //   url: "/admin/votings/excepturi-at/census/start_bulk_import",
  //   contentType: "application/json",
  //   data: null,
  //   headers: {
  //     "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
  //   }
  // }).done((response) => {
  //   console.log("createDataset response:", response);
  //   $("#processed_records").text("Started processing the census, please wait");
  // }).fail((error) => {
  //   console.log("error:", error)
  // });
}

const generateData = (rows) => {
  return $.ajax({
    method: "POST",
    url: "/admin/votings/excepturi-at/census/create_bulk_data",
    contentType: "application/json",
    data: JSON.stringify({ data: rows }),
    headers: {
      "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
    }
  }).done((response) => {
    console.log("processChunk response:", response);
    $("#processed_records").text(`Precessed records: ${response.processed}`);
  }).fail((error) => {
    console.log("error:", error)
  });
}

const notifyFinished = rowCount => {
  return $.ajax({
    method: "POST",
    url: "/admin/votings/excepturi-at/census/end_bulk_import",
    contentType: "application/json",
    data: JSON.stringify({ row_count: rowCount }),
    headers: {
      "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
    }
  }).done((response) => {
    console.log("notifyFinished response:", response);
    $("#processed_records").text(`Processing finished. Processed: ${response.processed}, total lines: ${rowCount}`);
  }).fail((error) => {
    console.log("error:", error)
  });
}

