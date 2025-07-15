document.addEventListener("DOMContentLoaded", () => {
  const waiting = document.querySelector(".waiting-room");
  if (!waiting) {
    return;
  }
  const dataUrl = waiting.dataset.url;
  if (!dataUrl) {
    return;
  }

  const checkStatus = async () => {
    const response = await fetch(dataUrl, {
      method: "GET",
      headers: {
        "Accept": "application/json", 
        "Content-Type": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    });
    if (response.ok) {
      const result = await response.json();
      if (result.url) {
        console.log("Redirecting to:", result.url);
        window.location.href = result.url;
      } else {
        setTimeout(checkStatus, 2000);
      }
    }
  };

  setTimeout(checkStatus, 2000);
});
