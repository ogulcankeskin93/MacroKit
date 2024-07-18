@attached(peer, names: suffixed(Mock))
public macro MockWorker() = #externalMacro(module: "MacroKitMacros", type: "MockWorkerMacro")
