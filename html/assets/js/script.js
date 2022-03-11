const signaturePad = new SignaturePad(document.getElementById("signature"), {
    backgroundColor: "rgba(255, 255, 255, 0)",
    penColor: "rgb(0, 0, 0)"
})

document.getElementById("clear").addEventListener("click", () => {
    signaturePad.clear()
})

document.getElementById("submit").addEventListener("click", () => {
    const base64 = signaturePad.toDataURL("image/png");

    fetch(`https://${GetParentResourceName()}/sign`, {
        method: "POST",
        body: JSON.stringify(base64)
    }).then(closeUI)
})

const replaceElements = {
    "to": {
        "name": ["to-name"],
    },
    "from": {
        "name": ["from-name"],
    },
    "invoice": {
        "id": ["invoice-id"],
        "issued": ["issue-date"],
        "due": ["due-date"]
    },
    "info": {
        "description": ["description"],
        "price": ["price1", "price2"]
    },
    "company": {
        "name": ["company"]
    }
}
function showUI(data) {
    signaturePad.clear()
    signaturePad.on()
    for (const [dataType, dataFields] of Object.entries(replaceElements)) {
        for (const [dataKey, elements] of Object.entries(dataFields)) {
            for (var i=0; i<elements.length;i++) {
                document.getElementById(elements[i]).innerText = data[dataType][dataKey];
            }
        }
    }

    document.getElementById("clear").style.display = data.signed ? "none" : "block"
    document.getElementById("submit").style.display = data.signed ? "none" : "block"
    document.getElementById("company-logo").src = `/html/assets/logos/${data.company.company}.png`

    if (data.signed) {
        signaturePad.fromDataURL(data.signature)
        signaturePad.off()
    }

    if (data.late > 0) {
        document.getElementById("late-payment").style.display = ""
        document.getElementById("late-days").innerText = data.late
        document.getElementById("interest").innerText = data.interest
        document.getElementById("late-amount").innerText = data.lateAmount
        document.getElementById("late-total").innerText = data.lateTotal
    } else {
        document.getElementById("late-payment").style.display = "none"
    }

    document.getElementById("total").innerText = data.total

    document.body.style.display = "block"
}

function closeUI() {
    document.body.style.display = "none"
    fetch(`https://${GetParentResourceName()}/close`, {method: "POST"})
}

window.addEventListener("message", (event) => {
    const data = event.data
    switch (data.action) {
        case "show":
            showUI(data)
            break
        case "close":
            closeUI()
            break;
        default:
            console.log(`Unknown action "${data.action}"`)
            break
    }
})

document.addEventListener("keydown", (event) => {
    if (event.key == "Escape") {
        closeUI()
    }
})