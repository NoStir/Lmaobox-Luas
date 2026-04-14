# http

*Source: https://lmaobox.net/lua/Lua_Libraries/http/*

---



# http


A lightweight HTTP library providing a simple get method for downloading data from the internet.


## Functions


### Get(url:string) : string


Returns string of the body response.


### GetAsync(url:string, callback(data:string) )


Non-blocking request using callback function as second argument


## Examples



```
local response = http.Get("https://catfact.ninja/fact");
print(response) 

--- prints {"fact":"A cat's hearing is much more sensitive than humans and dogs.","length":60}

```


```
http.GetAsync("https://catfact.ninja/fact", function(data) client.ChatSay(data) end)
--- says in chat {"fact":"A cat's hearing is much more sensitive than humans and dogs.","length":60}

```


