Config = {
    Framework = "qb", -- esx or qb

    -- esx options:
    MenuAlign = "bottom-right", -- the esx_menu_default menu location
    ReplaceESXBilling = true, -- replace esx billing? this will make the script work with esx_billing events

    Command = "bills",
    Keybind = {
        Enabled = true, -- should the script register a keybind?
        Mapper = "KEYBOARD", -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/
        Parameter = "F7"
    },
    UseRPName = true, -- should the transfer menu show the in-game name?
    MinAmount = 0, -- minimum bill amount
    MaxAmount = 900000000, -- max bill amount
    Signature = {
        SaveSignature = true,
        SaveAs = "imgur", --[[
            * base64: image will be saved as base64 in your database (takes a lot of storage)
            * imgur: image will be uploaded to imgur (put your API key in server/config.lua)
        ]]
    }
}