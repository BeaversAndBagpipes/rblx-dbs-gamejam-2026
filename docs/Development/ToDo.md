
## Code

- [ ] Update VERSION system? Not sure what should drive version number - git commit ID?
- [x] Singletons don't need metatables etc - can leave if cant be arsed
	- [x] Singletons should *not* call `Init` during require - call manually from inclusion script
- [x] References to other Singletons should be passed during `Init` instead of being required locally
	- [x] Dan? :Does this extend to everything, or just events?
	- [x] ?Dan: Should WindowManager load the child Windows itself, or do they get loaded in main
- [x] Event manager instances should be passed during `Init` rather than accessed directly via `_EventManager` - update existing Singletons to get Event instances via `Init`
- [x] Update code-snippets for Singletons and Classes to use new code 
- [x] Move server code to serverStorage folder - ServerScriptServcie should only include the entry point script
## Blender

- [ ] Test Blender -> Roblox plugin works in a shared Online Experience (OE)