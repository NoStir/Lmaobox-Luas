# filesystem

*Source: https://lmaobox.net/lua/Lua_Libraries/filesystem/*

---



# filesystem


This library provides a simple interface to the filesystem.


## Functions


### CreateDirectory( string:path )


Creates a directory at the specified relative or absolute path. Returns true if the directory was created, false if unsuccessful. Returns the full path as second return value.


### EnumerateDirectory( string:path, function( filename:string, attributes:integer ) )


Enumerates the files and directories in the specified directory. The callback function receives the filename and attributes of each file or directory.
The path is relative  to the game directory or absolute. You are not allowed to enumerate outside of the game directory.


### GetFileTime( string:path )


Returns 3 return values: the creation time, the last access time, and the last write time of the file at the specified path.


### GetFileAttributes( string:path )


Returns the attributes of the file at the specified path.


### SetFileAttributes( string:path, integer:attributes )


Sets the attributes of the file at the specified path.


## Examples


Create a directory inside the 'Team Fortress 2' directory
```
success, fullPath = filesystem.CreateDirectory( [[myContent]] )

```

Enumerate every file in the tf/ directory
```
filesystem.EnumerateDirectory( [[tf/*]] , function( filename, attributes )
 print( filename, attributes )
end )

```


