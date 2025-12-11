let rows = [];
const activeTags = new Set([]);

function filter(tag) {
  document.querySelectorAll(".tag").forEach((btn) => {
    if (btn.textContent.trim() === tag) {
      btn.classList.toggle("active", activeTags.has(tag));
    }
  });

  rows.forEach(({ row, tagSet }) => {
    const match = [...activeTags].every((item) => tagSet.has(item));
    row.classList.toggle("hidden", !match); // nuts
  });
}

document.addEventListener("DOMContentLoaded", () => {
  const table = document.querySelector("#index");
  if (!table) return;

  rows = Array.from(table.querySelectorAll("tbody tr")).map((row) => {
    const tagSet = new Set(
      Array.from(row.querySelectorAll(".tag"), (tag) => tag.textContent.trim()),
    );
    return { row, tagSet };
  });

  // Mobile view has no tags, avoids confusing users
  if (window.innerWidth > 649) {
    const pendingTag = sessionStorage.getItem("pendingTag");
    if (pendingTag) {
      activeTags.add(pendingTag);
      filter(pendingTag);
    }
  }
  sessionStorage.clear();

  table.addEventListener("click", (event) => {
    const element = event.target.closest(".tag");
    if (!element) return;

    const tag = element.textContent.trim();
    activeTags.has(tag) ? activeTags.delete(tag) : activeTags.add(tag);

    filter(tag);
  });
});

document.addEventListener("DOMContentLoaded", () => {
  const nav = document.querySelector("nav");
  if (!nav) return;

  document.querySelectorAll("a.link.tag").forEach((linkTag) => {
    linkTag.addEventListener("click", (event) => {
      event.preventDefault();

      sessionStorage.setItem("pendingTag", linkTag.textContent.trim());

      const href = linkTag.getAttribute("href");
      window.location.href = href;
    });
  });
});
