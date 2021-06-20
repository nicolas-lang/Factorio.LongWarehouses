-- Arrays are call be ref, therefore assignment of array members work without write-back
_G.ncoData = _G.ncoData or {}
local myGlobal = ncoData.LongWarehouses or {}
myGlobal.whSizes = myGlobal.whSizes or {}
myGlobal.RegisteredWarehouses = myGlobal.RegisteredWarehouses or {}
return myGlobal
