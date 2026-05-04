new MutationObserver(() => {
    const titleLabelDivs = document.querySelectorAll(".title-label");
    titleLabelDivs.forEach((div) => {
        const h2Element = div.querySelector("h2");
        if (h2Element && h2Element.textContent.startsWith("Explorer:")) {
            h2Element.textContent = h2Element.textContent.replace("Explorer:", "").trim();
        }
    });
}).observe(document.body, { childList: true, subtree: true });
