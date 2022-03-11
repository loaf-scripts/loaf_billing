Strings = {
    ["select_menu"] = "Select menu",
    ["unsigned_bill"] = "Unsigned",
    ["signed_bill"] = "Signed",

    ["unsigned_bills"] = "Unsigned invoices",
    ["signed_bills"] = "Signed invoices",
    ["bill_item"] = "[%s] %s",
    ["no_bills"] = "No invoices",

    ["view_bill"] = "View invoice",
    ["transfer_bill"] = "Transfer invoice",

    ["who_transfer"] = "Who do you want to transfer the invoice to?",
    ["confirm_transfer"] = "Transfer \"%s\" to %s?",

    ["sent_bill"] = "You sent an invoice of ~g~$%i~s~ to ~b~%s",
    ["received_bill"] = "You received an invoice of ~r~$%i",

    ["transferred_bill"] = "You sent ~y~%s~s~ to ~b~%s",
    ["received_transfer"] = "You received ~y~%s~s~ from ~b~%s",

    ["bill_paid"] = "~y~%s~s~ (~g~$%i~s~) was paid by ~b~%s",

    ["keybind"] = "View invoices",

    ["no_money"] = "You don't have enough money.",

    ["yes"] = "Yes",
    ["no"] = "No",

    ["back"] = "Go back",
    ["close"] = "Close menu",
}

-- ignore this
setmetatable(Strings, {__index = function(self, key)
    print("NO KEY", key)
    return "Error: Missing translation for \""..key.."\""
end})