{{/*
    Name: pagination.cc.lua
    This command manages the pagination of certain embeds

    Dont change anything!

    Trigger: Reaction with "Added Reactions Only" option
/*}}

{{/* ACTUAL CODE! DONT TOUCH */}}
{{/* VARIABLES */}}
{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
{{$ticketOpen := $setup.ticketOpen}}{{$ticketClose := $setup.ticketClose}}{{$ticketSolving := $setup.ticketSolving}}
{{$emoji := .Reaction.Emoji.Name}}
{{$t2 := "Ticket ID: "}}
{{$RM := .ReactionMessage}}
{{$isTicketEmbed := false}}
{{$est := ""}}{{$msg := ""}}{{$pM := ""}}{{$embed := ""}}{{$titulo := ""}}{{$timed := ""}}{{$s1 := "" }}{{$s2 := ""}}{{$s3 := ""}}{{$fields := ""}}{{$tn := 0}}{{$skip := 0}}{{$page := 0}}{{$pA := ""}}{{$pM := ""}}
{{$upEmoji := "▶️"}}
{{$downEmoji := "◀️"}}
{{/* END OF VARIABLES */}}

{{/* START */}}
{{if and (eq $RM.Author.ID 204255221017214977) (reFind `These are your server tickets:` $RM.Content)}}
    {{$page := reFind `Page: \d+` .ReactionMessage.Content | reFind `\d+`}}
    {{if eq $emoji $upEmoji}}{{$page = add $page 1}}{{else if eq $emoji $downEmoji}}{{$page = sub $page 1}}{{end}}
    {{deleteMessageReaction nil $RM.ID .User.ID $upEmoji $downEmoji}}
    {{if ge (toInt $page) 1}}
        {{$skip = mult (sub $page 1) 25}}
        {{$tickets := dbTopEntries "ticket" 25 $skip}}
        {{if len $tickets}}
            {{$msg = printf "%s\t%-12s\t%-19s\t%-10s\t%-12s\t%-25s\n" "TK_ID" "Opened by" "Opened at" "Status" "MOD" "AutoDel"}}
            {{range $tickets}}
                {{$tn = toInt .Value.ticketID}}
                {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}} {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}} {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}} {{end}}
                {{if ge (toInt .Value.resp) 1}} {{$pm = .Value.respArg.Username}} {{if gt (len $pm) 12}} {{$pM = slice $pm 0 12}} {{else}} {{$pM = $pm}} {{end}} {{else}} {{$pM = "Nobody"}} {{end}}
                {{if or (eq (toInt .Value.alert) 3) (eq (toInt .Value.pos) 3)}} {{$timed = 0}}
                {{else}}
                    {{if eq (toInt .Value.alert) 1}} {{$timed = humanizeDurationHours ((.Value.duration).Sub currentTime)}}
                    {{else if eq (toInt .Value.alert) 2}} {{$timed = humanizeDurationMinutes ((.Value.duration).Sub currentTime)}}
                    {{end}}
                {{end}}
                {{$createdAt := .Value.ctime.Format "1 _2 2006 15:04 UTC"}}{{$autor := .Value.creator.Username}}
                {{if gt (len $autor) 12}}{{$pA = slice $autor 0 12}}{{else}}{{$pA = $autor}}{{end}}
                {{$msg = print $msg (printf "%05d\t%-12s\t%-19s\t%-10s\t%-12s\t%-25s\n" $tn $pA (str $createdAt) $est $pM (str $timed))}}
            {{end}}
        {{$embed = print "These are your server tickets:\nPage: " $page "\n```" $msg "```"}}
        {{editMessage nil $RM.ID $embed}}
        {{end}}
    {{end}}
{{end}}

{{with and (eq $RM.Author.ID 204255221017214977) $RM.Embeds}}
    {{$eID := index . 0}}
    {{if and (eq $eID.Title "These are your server tickets:") $eID.Footer}}
        {{$page = reFind `\d+` $eID.Footer.Text}}
        {{$isTicketEmbed = true}}
    {{end}}
{{end}}
{{if $isTicketEmbed}}
    {{deleteMessageReaction nil $RM.ID .User.ID $upEmoji $downEmoji}}
    {{if eq $emoji $upEmoji}} {{$page = add $page 1}} {{else if eq $emoji $downEmoji}} {{$page = sub $page 1}} {{end}}
    {{if ge (toInt $page) 1}}
        {{$skip = mult (sub $page 1) 24}}
        {{$tickets := dbTopEntries "ticket" 24 $skip}}
        {{if len $tickets}}
            {{range $tickets}}
                {{$tn = toInt .Value.ticketID}}
                {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}} {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}} {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}} {{end}}
                {{$autor := .Value.creator}}
                {{$s1 = joinStr "\n" $s1 $tn}}{{$s2 = joinStr "\n" $s2 $autor.Username}}{{$s3 = joinStr "\n" $s3 $est}}
            {{end}}
            {{$fields = (cslice
                    (sdict "name" "Ticket ID" "value" $s1 "inline" true)
                    (sdict "name" "Created By" "value" $s2 "inline" true)
                    (sdict "name" "Status" "value" $s3 "inline" true)
            )}}
            {{$titulo = "These are your server tickets:"}}
            {{$embed = cembed "title" $titulo "fields" $fields "color" 3066993 "footer" (sdict "text" (print "Page: " $page))}}
            {{$out := editMessage nil $RM.ID $embed}}
        {{end}}
    {{end}}
{{end}}
