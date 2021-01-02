# RobloxMusicReplacer
A dirty ROBLOX music replacer for Windows
Tested working as of November 2019
I am not offering any support for this. Thus it has been archived.

This utility can cause instabilities in ROBLOX, wherein no new assets will be downloaded, if this occurs, restart ROBLOX.

When replacing music, the music needs to be reloaded to load the modified track.

# Use

REQUIRED: Download handle64 and put it in the same folder https://download.sysinternals.com/files/Handle.zip

You need to get the MD5 hash of the songs you are going to replace, this is located in $env:TEMP\Roblox\sounds\
Modify the array $replace accordingly in ReplaceFiles.ps1
There are some examples for the ROBLOX game Flee The Facility
To start, launch Start.bat and join your game on ROBLOX
