-- Arrays are call be ref, therefore assignment of array members work without write-back
local ncoData = _G.ncoData or {}
local myGlobal = ncoData.LongWarehouses or {}
myGlobal.whSizes = myGlobal.whSizes or {}
myGlobal.RegisteredWarehouses = myGlobal.RegisteredWarehouses or {}
return myGlobal
