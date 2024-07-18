@attached(member, names: arbitrary)
public macro Fake() = #externalMacro(module: "MacroKitMacros", type: "FakeMacro")
