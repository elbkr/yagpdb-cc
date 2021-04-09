
## Music
### Features:
- Lots of feedback, telling you exactly why it's not doing what you want it to do
- Doesn't need the exact name, it tries to find the song based on your input
- Commands are usable as single letters: `-music play Hotel California` = `-m p Hotel California` and `-music random` = `-m r`.
- Auto recognises the artist and title and duration straight from the soundboard if you use the following formatting: `Artist name - This is the title [228]`
  - "Artist name" should be the artists name
  - "This is the title" should be the title of the song
  - "228" should be the duration of the song in seconds (`228` => 3 minutes and 48 seconds)

### Usage:
- Trigger should be Regex: `\A-m(usic)?(\s+|\z)`
- Resuming playback, playing a song (next): `-music play [songname]`
- Queuing songs or viewing the queue: `-music queue [songname]`
- Skipping currently playing songs: `-music skip`
- List of available songs: `-music list`
- Ending the playback: `-music end`
- Clearing the queue: `-music clear`
- Queuing a random song: `-music random`
