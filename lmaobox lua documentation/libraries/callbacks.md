# callbacks

*Source: https://lmaobox.net/lua/Lua_Libraries/callbacks/*

---



# callbacks


## Functions


Callbacks are functions that are called when a certain event occurs. Yiu can use them to add custom functionality to your scripts. To see the list of available callbacks, see the callbacks page.


### Register( id, function )


Registers a callback function to be called when the event with the given id occurs.


### Register( id, unique, function )


Registers a callback function to be called when the event with the given id occurs. If the callback function is already registered, it will not be registered again.


### Unregister( id, unique )


Unregisters a callback function from the event with the given id.


## Examples



