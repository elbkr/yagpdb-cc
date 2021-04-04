{{/*
    JSON Converter CC (JSONify)

    Made By Devonte#0745 / Naru#6203

    Recommended Trigger Type: Command
    Recommended Trigger: json

    See README.md for more info on use.

    © NaruDevnote 2020-2021 (GNU GPL v3)
    https://github.com/devnote-dev/yagpdb-ccs
*/}}

{{$a := parseArgs 2 "```json <Channel:Mention> <messageID>\njson <Channel:Name> <messageID>\njson <Channel:ID> <messageID>\njson 0 <messageID>\n```**Optional Flags:**\n```\n[-j strict-format:flag]\n[-file/f attachment:flag]```"
(carg "string" "chan") (carg "int" "msgID") (carg "string" "flag: -j | -f")}}
{{$type := dict 0 "Default Message" 6 "Pinned Message" 7 "Join Message" 8 "Boost Message" 9 "Teir 1 Boost Message" 10 "Teir 2 Boost Message" 11 "Teir 3 Boost Message" 12 "Followed Channel Message" 19 "Reply Message"}}
{{$struct := "Unknown"}}{{$ver := "JSONify v4.15"}}{{$fa := false}}{{$chan := .Channel}}
{{$link := joinStr "/" "https://discordapp.com/channels" .Guild.ID .Channel.ID ($a.Get 1)}}{{$ctx := ""}}

{{$l := sendMessageRetID nil (cembed "description" "Converting Message... <a:loading:760219029620523008>")}}
{{if ne ($a.Get 0) "0"}}
    {{$chan = getChannel (or (reFind `\d+` ($a.Get 0)) ($a.Get 0))}}
    {{$link = joinStr "/" "https://discordapp.com/channels" .Guild.ID $chan.ID ($a.Get 1)}}
{{end}}
{{if ($msg := getMessage $chan.ID ($a.Get 1))}}
    {{with $msg.Embeds}}{{$struct = print (title (index . 0).Type) " Embed"}}{{else}}
    {{$struct = or (and $msg.Attachments "Attachment Message") (and (eq $msg.Type 0 6 7 8 9 10 11 12 19) ($type.Get (toInt $msg.Type))) $struct}}
    {{end}}
    {{$time := div $msg.ID 4194304|mult 1000000|toDuration}}
    {{$json := json $msg}}
    {{if ($a.IsSet 2)}}
        {{if (reFind `-j` ($a.Get 2))}}{{$json = reReplace `,` $json ",\n"}}{{end}}
        {{if (reFind `-f(?:ile)?` ($a.Get 2))}}{{$ctx = "The downloadable file attachment will be sent shortly. 👌"}}{{$fa = true}}{{end}}
    {{end}}
    {{if or (ge (len $json) 2048) (reFind `\[(?:{.*},?){4,}\]` $json)}}
        {{$ctx = "The message you requested was either too big or contained something that would crash the CC. To prevent this, a downloadable attachment version will be sent instead."}}
        {{$fa = true}}
    {{end}}
    {{if $fa}}
        {{deleteMessage nil $l 0}}
        {{sendMessage nil (complexMessage "content" $ctx "file" (printf "REQUESTED BY: %s (%d)\nDATE/TIME: %s\nGUILD: %s (%d)\nCHANNEL: %s (%d)\nSNOWFLAKE: %s\nJSON:\n\n%s" .User.String .User.ID currentTime .Guild.Name .Guild.ID .Channel.Name .Channel.ID $time $json))}}
    {{else}}
        {{$e := cembed
            "author" (sdict "name" (print "Triggered by " .User.String) "icon_url" (.User.AvatarURL "256"))
            "title" "JSON Output"
            "description" (print "```json\n" $json "\n```")
            "fields" (cslice
                (sdict "name" "Channel" "value" (print "<#" $chan.ID ">\n(ID " $chan.ID ")") "inline" true)
                (sdict "name" "Message ID" "value" (print ($a.Get 1) "\n[Click here](" $link ") to go to message.") "inline" true)
                (sdict "name" "Message Type" "value" $struct "inline" true)
                (sdict "name" "Snowflake (Age)" "value" (humanizeDurationSeconds (currentTime.Sub ($time|.DiscordEpoch.Add))) "inline" true)
                (sdict "name" "Size" "value" (print (fdiv (len $json) 1000) "kb") "inline" true))
            "footer" (sdict "text" $ver)}}
        {{editMessage nil $l (complexMessageEdit "embed" $e)}}
    {{end}}
{{else}}
    {{editMessage nil $l (complexMessageEdit "embed" (cembed "title" "Error" "description" "Unkown message. Please try again."))}}
{{end}}
