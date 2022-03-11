# Loaf Billing - FiveM Invoice / Billing Script for ESX & QBCore

## Features
* NUI, not only pressing a button in a menu
* Interest - pay x% extra for each day you haven't signed
* Signature - you need to actually sign the invoice, and this signature can be saved
* Transfer invoice - you can send your invoice to other players so they can view it (they will not be able to sign it)
* An event, `loaf_billing:bill_paid` containing all data, will be triggered upon payment

## Configuration
You can translate the script in shared/language.lua  
You can set your Imgur API key in server/config.lua

All other configurations are done in shared/config.lua
* Framework - the framework you use, esx or qb
* ReplaceESXBilling - add `esx_billing:sendBill` event?
* Command - the command to open the menu
* Keybind - keybind options
  * Enabled - should the script register a keybind for the menu?
  * Mapper - the mapper for the keybind, see: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/ (e.g: KEYBOARD)
  * Parameter - the key, e.g: F7
* UseRPName - should the transfer menu show the in-game name, or the Steam/FiveM name?
* MinAmount - the minimum amount when creating an invoice
* MaxAmount - the maximum amount when creating an invoice
* Signature - signature options
  * SaveSignature - should the signature be saved? note: sends base64 from client --> server which may cause server lag
  * SaveAs - how should the signature be saved? imgur or base64

## Requirements
* [loaf_lib](https://github.com/loaf-scripts/loaf_lib)
* (should already be on your server) [mysql-async](https://github.com/brouznouf/fivem-mysql-async) or [oxmysql](https://github.com/overextended/oxmysql/)
* (qb only) [qb-menu](https://github.com/qbcore-framework/qb-menu)
