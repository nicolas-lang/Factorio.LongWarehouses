# Factorio: Long warehouses
When playing Factorio with Logistic Train Network enabled, I never liked the micro management of balancing the individual chests with the exact amount of resources for each cargo waggon. Especially with a large base and a mod-heavy game the required circuits and entities introduced a UPS sink that felt unnecessary.

This mod adds larger warehouses (with configurable sizes) to simplify building better, simpler train stations.

It is kind of a hack since Factorio does not allow you to rotate chests... 
- you place a pump that looks like a warehouse
- then the mod replaces it in the background with one of the two possible warehouses
- replacing also introduces some circuit related issues that are handled by creating a composite entity with a dedicated connection pole
- which in return requires additional hacks to ensure the composite entity is set up correctly all the time

Feel free to review and improve my code.
##Known Issues
- Fast replace, Ctrl-Z, and chest-upgrade is broken
- I tried to move around the limitations of the factorio api, it should work like 95% of the time...
- I appreciate help for the remaining 5%

## Acknowledgements

- **Huge thanks to Mernom and Test447 from Earendel's discord for their help with modding related issues**
- [Github actions based on Roang-zero1 Actions](https://github.com/Roang-zero1)
- [Logistic Train Network is a mod by Optera](https://mods.factorio.com/mods/Optera/LogisticTrainNetwork)

