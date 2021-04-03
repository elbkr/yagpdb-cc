# Reaction-Ticket-CC
**IMPORTANT NOTE:** If you are using this CC, you **MUST DISABLE** all tickets commands.<p>
Also, ***never*** change the name of a ticket chat.<p><p>

If you were using the older version of this system, I **highly** recommend you update **ALL** the CCs. A lot of bugs have been fixed.
Also, after that, you will need to run the setuptickets command once more. 
Don't worry, your already opened tickets won't be affected. 

## Features
1. Tickets work fully with reactions. You can open, close, reopen, delete, save transcript, make it admin only, etc, all with reactions.
1. Extra ticket functionalities (with command -checktickets):
	1. This command has an alias (-ct)
		1. FullList (aliases: fl, full, big): Shows you the 25 most recent tickets of the server. Doesn't work well with Discord Mobile. It has a pagination system so you can scroll to older tickets.
		1. SmallList (aliases sl, small): Same as above but more concise. Only show 3 infos instead of all infos. Also has a pagination system. It shows the 24 most recent tickets, instead of 25.
		1. Exact ticket (for example: -ct 96): Shows all the info about the specifed ticket. If you are **premium** at [YAGPDB](https://yagpdb.xyz/), this feature will also have a pagination system.
		1. Newest (aliases: n, new): Same as above, but instead of exact ticket, shows the most recent one.
		1. Oldest (aliases: o, old): Same as above, but instead of the most recent ticket, shows the oldest one.
		1. Examples of use: -ct o | -ct new | -checktickets fl
1. Ability to reopen ticket after its closed.
1. Ability to save transcripts without deleting the ticket.
1. Use command $add and $remove to add/remove users to/from the ticket.
	1. Maximum of 15 users per ticket.
		1. **Why not use the built-in add command?** Because that doesn't allow you to reopen the ticket.
1. Automatically deletes tickets after x amount of time with no messages sent. Only applies to open tickets. Closed ones will have to be deleted manually.
1. Handy **-resend** command. This deletes the original first message of the ticket and resends it. It's good to close the ticket without having to scroll all the way up to find the message.
1. Has a display in a specific channel that shows status of tickets. (Explained further in F.A.Q.)

## How To Install
Copy and paste every command to your server. All the instructions are at the top of each command.<p>
You dont need to change anything in any command, except for the setup command.<p>
After you created all the commands at your control panel, change the settings in the setup command and then run it once.<p>
It will return with all your settings. If everything is correct, the system is good to go.<p>
If you found a mistake in your settings, change it and run the command again.<p>
After that you can delete the setup command.<p>

## F.A.Q.
1. What is that display thingy? What is this `$masterTicketChannelID` variable in the setup?<p>
	In version 1.0, the ticket system used to change the ticket name based on it's status. So, for example, if a ticket was open, the channel name would be `01-open`. If it was closed, the channel name would be `01-closed` and so on.<p>
	But, discord have changed the API rate limit to edit a channel name, which caused this function to run into trouble.<p>
	So, in other to avoid that, and to make admins/mods be able to quickly see the status of tickets, I created a display system.<p>
	This is where the $masterTicketChannelID variable comes in. The display will be an embed in that channel. This embed will be frequently updated by the bot showing the status of the 50 most recent tickets.
1. Can you join in my server and set it up for me?<p>
	No.
1. Is there an official video showing the system and how to set it up?<p>
	No, but I might make one at some point.

### Screenshots
<h1 align="center"><img src="https://imgur.com/IpFJWNq.png" height=341px width=890px></img><p><p>
<h1 align="center"><img src="https://imgur.com/4eozdra.png" height=354px width=428px></img><p><p>
<h1 align="center"><img src="https://imgur.com/LaQQoQp.png" height=753px width=923px></img><p><p>
<h1 align="center"><img src="https://imgur.com/48f5tia.png" height=222px width=452px></img><p><p>
<h1 align="center"><img src="https://imgur.com/op7WvMj.png" height=810px width=700px></img><p><p>
