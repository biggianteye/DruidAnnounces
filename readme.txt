The addon announces spells such as innervate or rebirth to raid-chat or whisper-targets.
At that, it is sensitive to spell-failures such as Out-of-Range or Line-of-Sight.

What it does:
Announce in the raid/party-chat when you cast Rebirth. (Only if the spell is actually casted, which can't be achieved with macros)
Whisper the spell target when you cast Innervate.
Whisper the targeted player when an Innervate or Rebirth failed because of Line-of-sight or Out-of-range.
It is possible to modify the addon to do any kind of wispers/announces on any spell (depending if it succeded or failed due to LoS/OoR)


Install:
Just copy the "DruidAnnounces" folder to your "World of Warcraft/Interface/AddOns" folder.
You might have to enable out-of-date addons or update the .toc file in case the version numbers don't match.

Setup:
The addon is enabled by default. It does not consume a noticible amount of system resources.
You can disable or enable the addon using the "/druidannounces" command. It will be enabled by default at restart.
To change or add announces, you can edit the "setup.lua" file. (basic understanding of the lua language required)

Testing:
You can change to debug mode with "/druidannounces debug".
0 -> normal mode
1 -> silent mode (no whispers or chat messages), announces for "Healing Touch" & "Rejuvenation" will be activated (to test without cooldown)
2 -> additional debug messages


Please comment if you experience any bugs.
Add this addon to your favorites to keep you informed on updates.
Feel free to post your setup.lua changes in the comments, to give other users an idea of how spell announces can be altered.


Changelog:

4.2:
* Adapted to new COMBAT_LOG_EVENT_UNFILTERED
* Won't whisper yourself anymore on innervate (when using the default setup.lua)

4.1c:
* Multi-language support
* German localization (other languages work, but with english announces)
* Fixed party/raid channel announces
* Added the "success" tag for cast-time spells
* Added support for channel names in announces in addition to channel numbers

4.1b:
* Moved announces to setup.lua to allow for easy editing of announces.

4.1:
* Adapted to new COMBAT_LOG_EVENT_UNFILTERED

4.0:
* Rewritten for Cataclysm
* Added Option for announces to channels

3.0:
* Update for Wotlk

1.4:
* Changed code to easily add any other spell (class independend)
* No 'Out of range' announces when the spell is on cooldown.
* Fixed German rebirth

1.3:
* ANSI -> UTF-8 (German special characters)
* Finished German translation.
* Bugfixing (with non-los & non-oor errors)
* more Bugfixing (leaving debug mode now switches back to the original spells)

1.2:
* Code optimization, which got rid of some rare bugs.
* Little redesign of the debug mode (to avoid mistakes like in 1.1)

1.1b:
* Fixed localization.lua to use correct spellnames

1.1:
* Got rid of the .xml file
* Improved setup.lua
* Localized announces
* German localization

1.0:
* 1st release



Druid Announces has be reclaimed by its original Author and is being updated to current patch versions (4.1+)

Original & current Author: Prisma / Neetha at Destromath(eu).
Updates during wotlk: Jonny283829