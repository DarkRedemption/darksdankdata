# Dark's Dank Data
Dark's Dank Data (DDD) is a free, open-source stats, ranks, and (eventually) achievements tracker for the *Garry's Mod* Gamemode *Trouble in Terrorist Town* (TTT).

## Design Goals
* **No Required Dependencies** - DDD is meant to be instantly usable by simply dropping it into your server's addons folder. Optional dependencies, such as UTime, can be installed to automatically enable additional functionality.
* **No Configuration Necessary** - As an extension of the above, it is not required for a config file to be changed or for anything to be done for it to simply work.
* **Thorough Tests** - [GUnit](http://www.github.com/darkredemption/gunit), a *Garry's Mod* Testing Framework, was developed specifically to create tests for DDD to help guarantee everything works properly, even in the presence of additional addons.

## Features
* Tracks nearly everything, including:
  * Kills
  * Deaths
  * Shots fired
  * Damage Dealt
  * Items Purchased
  * ttt_radio Callouts
  * Credits Looted
  * ...and more!
* Ranking system with configurable prerequisites to be listed
* Minimum population setting to not ruin stats when people are populating and not playing a full TTT game (such as 1v1s or 1v6s)

## Currently Implemented
* Vanilla Ranks/Stats for every class/role
* Dynamic Weapon/Shop Item Detection (Tracked but not displayed)

## To be Implemented
* Achievement System
* Dynamic Weapon/Shop Item Stats/Ranks Display
* Time Sliced Stats/Ranks
* Disabling of DDD temporarily by vote
* MySQL Support
* Even more stats (T-Trap Kills, Teleports, Score, etc)

## Installation
1. Click the green "Clone or Download" button on the Github page.
2. Choose "Download Zip".
3. Place the contents of the zip file in your server's addons folder.

## Usage
In game, type "!dank" in chat or "ddd" in console, without the quotes in both cases.

## Note about updates
DDD is still under active development, including its database components. Since these may change, this could cause !dank to fail. If it does, it is looking for aggregate data columns that are new and do not exist in your database. If this happens, take the following steps:

1. Turn off your production server.
2. Download your server's SQLite database (the sv.db file).
3. Load the sv.db file into a local test server.
4. Type ddd_recalculate in the server console. This drops your aggregate stats tables, re-creates them to add their new columns, and repopulates the columns with data from other tables.
5. Once complete, re-upload the now-modified sv.db file back to your production server.
6. Restart your production server.

## License
DDD is MIT Licensed.
