{{/*
    Name: checkTicket.cc.lua
    Master command: -CheckTickets (alias -ct)
    Sub commands: FullList (fl|full|big) / SmallList (sl|small) / Oldest (o|old) / Newest (n|new) / Exact Ticket, for example -ct 107
    Trigger: Regex
    Regex: \A-(((checktickets|ct) (o(ld(est)?)?|n(ew(est)?)?|full(list)?|fl|big|small(list)?|sl|\d+))|(checktickets|ct))\z
    Dont change anything!
/*}}


{{/*ACTUAL CODE! DONT TOUCH*/}}
{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
{{$ticketOpen := $setup.ticketOpen}}{{$ticketClose := $setup.ticketClose}}{{$ticketSolving := $setup.ticketSolving}}
{{$est := ""}}{{$d := 0}}{{$msg := ""}}{{$pm := ""}}{{$embed := ""}}{{$timed := ""}}{{$s1 := "" }}{{$s2 := ""}}{{$s3 := ""}}{{$s4 := "" }}{{$s5 := ""}}{{$fields := ""}}{{$t1 := "These are your server tickets:"}}{{$t2 := "Ticket ID: "}}{{$t := ""}}{{$f := "🎟️"}}{{$tn := 0}}{{$pA := ""}}{{$pM := ""}}
{{$cmd := reFind `(?i)o(ld(est)?)?|n(ew(est)?)?|full(list)?|fl|big|small(list)?|sl|\d+` .Cmd}}{{$getNumber := reFind `\d+` $cmd}}{{$c := 3066993}}
{{$ME := cembed "title" "NO TICKETS OPENED" "description" "All tickets already solved" "color" $c}}

{{if reFind `(?i)fl|full|big` $cmd}}
    {{$tickets := dbTopEntries "ticket" 25 0}}
    {{if eq (len $tickets) 0}} {{$d = 1}}
    {{else}}
        {{$msg = printf "%s\t%-12s\t%-19s\t%-10s\t%-12s\t%-25s\n" "TK_ID" "Opened by" "Opened at" "Status" "MOD" "AutoDel"}}
        {{$d = 2}}
        {{range $tickets}}
            {{$tn = toInt .Value.ticketID}}
            {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}} {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}} {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}} {{end}}
            {{if ge (toInt .Value.resp) 1}} {{$pm = .Value.respArg.Username}} {{if gt (len $pm) 12}} {{$pM = slice $pm 0 12}} {{else}} {{$pM = $pm}} {{end}} {{else}} {{$pM = "Nobody"}} {{end}}
            {{if or (eq (toInt .Value.alert) 3) (eq (toInt .Value.pos) 3)}} {{$timed = "0"}} {{else}} {{if eq (toInt .Value.alert) 1}} {{$timed = humanizeDurationHours ((.Value.duration).Sub currentTime)}}{{else if eq (toInt .Value.alert) 2}} {{$timed = humanizeDurationMinutes ((.Value.duration).Sub currentTime)}} {{end}} {{end}}
            {{$createdAt := .Value.ctime.Format "01/02/2006 15:04 UTC"}}{{$autor := .Value.creator.Username}}
            {{if gt (len $autor) 12}}{{$pA = slice $autor 0 12}}{{else}}{{$pA = $autor}}{{end}}
            {{$msg = print $msg (printf "%05d\t%-12s\t%-19s\t%-10s\t%-12s\t%-25s\n" $tn $pA $createdAt $est $pM $timed)}}
        {{end}}
    {{end}}
    {{if eq $d 1}} {{sendMessage nil $ME}}
    {{else if eq $d 2}} {{$embed = print $t1 "\nPage: 1\n```" $msg "```"}} {{$out := sendMessageRetID nil $embed}} {{addMessageReactions nil $out "◀️" "▶️"}}
    {{end}}
{{else if reFind `(?i)sl|small` $cmd}}
    {{$tickets := dbTopEntries "ticket" 24 0}}
    {{if eq (len $tickets) 0}} {{$d = 1}}
    {{else}}
        {{$d = 2}}
        {{range $tickets}}
            {{$tn = toInt .Value.ticketID}}
            {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}} {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}} {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}} {{end}}
            {{$autor := .Value.creator}}
            {{$s1 = joinStr "\n" $s1 $tn}}{{$s2 = joinStr "\n" $s2 $autor.Username}}{{$s3 = joinStr "\n" $s3 $est}}
        {{end}}
    {{end}}
    {{$fields = cslice (sdict "name" "Ticket ID" "value" $s1 "inline" true) (sdict "name" "Created By" "value" $s2 "inline" true) (sdict "name" "Status" "value" $s3 "inline" true)}}
    {{if eq $d 1}} {{sendMessage nil $ME}}
    {{else if eq $d 2}}
        {{$embed = cembed "title" $t1 "fields" $fields "color" $c "type" "small" "footer" (sdict "text" "Page: 1")}} {{$out := sendMessageRetID nil $embed}} {{addMessageReactions nil $out "◀️" "▶️"}}
    {{end}}
{{else if $getNumber}}
    {{with (dbGet (toInt $getNumber) "ticket").Value}}
        {{$d = 2}} {{$creator := .creator}} {{$createdAt := .ctime.Format "01/02/2006 15:04 UTC"}}
        {{if eq (toInt .pos) 1}} {{$est = $ticketOpen}} {{else if eq (toInt .pos) 2}} {{$est = $ticketSolving}} {{else if eq (toInt .pos) 3}} {{$est = $ticketClose}} {{end}}
        {{$t = print $t2 .ticketID}}
        {{range dbTopEntries "ticket" 1 0}} {{if (eq (toInt .Value.ticketID) (toInt $getNumber))}} {{$f = "Newest 🎟️"}} {{end}} {{end}}
        {{range dbBottomEntries "ticket" 1 0}} {{if (eq (toInt .Value.ticketID) (toInt $getNumber))}} {{$f = "Oldest 🎟️"}} {{end}} {{end}}
        {{if ge (toInt .resp) 1}} {{$pM = .respArg.Username}} {{else}} {{$pM = "Nobody"}} {{end}}
        {{if or (eq (toInt .alert) 3) (eq (toInt .pos) 3)}} {{$timed = "0"}}
        {{else}}
            {{if eq (toInt .alert) 1}} {{$timed = humanizeDurationHours ((.duration).Sub currentTime)}}
            {{else if eq (toInt .alert) 2}} {{$timed = humanizeDurationMinutes ((.duration).Sub currentTime)}}
            {{end}}
        {{end}}
        {{$fields = cslice
            (sdict "name" "Creator" "value" $creator.Username "inline" true)
            (sdict "name" "Created At" "value" $createdAt "inline" true)
            (sdict "name" "Status" "value" $est "inline" true)
            (sdict "name" "MOD" "value" $pM "inline" true)
            (sdict "name" "AutoDel" "value" $timed "inline" true)}}
    {{else}}{{$d = 1}}
    {{end}}
    {{if eq $d 1}} {{$embed = cembed "title" "Non existant ticket" "description" (print "I searched the whole server, but looks like ticket " $getNumber " does not exist!") "color" 16711680}} {{sendMessage nil $embed}}
    {{else if eq $d 2}}
        {{$embed = cembed "title" $t "fields" $fields "color" $c "footer" (sdict "text" $f)}} {{$out := sendMessageRetID nil $embed}}
        {{if .IsPremium}}{{addMessageReactions nil $out "◀️" "▶️"}}{{end}}
    {{end}}
{{else if or (not $cmd) (reFind `(?i)n` $cmd)}}
    {{$tickets := dbTopEntries "ticket" 1 0}}
    {{if eq (len $tickets) 0}}{{$d = 1}}
    {{else}}
        {{range $tickets}}
            {{$d = 2}} {{$creator := .Value.creator}} {{$createdAt := .Value.ctime.Format "01/02/2006 15:04 UTC"}}
            {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}}
            {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}}
            {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}}
            {{end}}
            {{$t = print $t2 .Value.ticketID}}
            {{if ge (toInt .Value.resp) 1}} {{$pM = .Value.respArg.Username}} {{else}} {{$pM = "Nobody"}} {{end}}
            {{if or (eq (toInt .Value.alert) 3) (eq (toInt .Value.pos) 3)}} {{$timed = "0"}}
            {{else}}
                {{if eq (toInt .Value.alert) 1}} {{$timed = humanizeDurationHours ((.Value.duration).Sub currentTime)}}
                {{else if eq (toInt .Value.alert) 2}} {{$timed = humanizeDurationMinutes ((.Value.duration).Sub currentTime)}}
                {{end}}
            {{end}}
            {{$s1 = $creator.Username}}{{$s2 = $createdAt}}{{$s3 = $est}}{{$s4 = $pM}}{{$s5 = $timed}}
        {{end}}
    {{end}}
    {{$fields = cslice
        (sdict "name" "Creator" "value" $s1 "inline" true)
        (sdict "name" "Created At" "value" $s2 "inline" true)
        (sdict "name" "Status" "value" $s3 "inline" true)
        (sdict "name" "MOD" "value" $s4 "inline" true)
        (sdict "name" "AutoDel" "value" $s5 "inline" true)}}
    {{if eq $d 1}} {{sendMessage nil $ME}}
    {{else if eq $d 2}}
        {{$embed = cembed "title" $t "fields" $fields "color" $c "footer" (sdict "text" "Newest 🎟️")}} {{$out := sendMessageRetID nil $embed}}
        {{if .IsPremium}} {{addMessageReactions nil $out "◀️" "▶️"}} {{end}}
    {{end}}
{{else if reFind `(?i)o` $cmd}}
    {{$tickets := dbBottomEntries "ticket" 1 0}}
    {{if eq (len $tickets) 0}}{{$d = 1}}
    {{else}}
        {{range $tickets}}
            {{$d = 2}} {{$creator := .Value.creator}} {{$createdAt := .Value.ctime.Format "01/02/2006 15:04 UTC"}}
            {{if eq (toInt .Value.pos) 1}} {{$est = $ticketOpen}}
            {{else if eq (toInt .Value.pos) 2}} {{$est = $ticketSolving}}
            {{else if eq (toInt .Value.pos) 3}} {{$est = $ticketClose}}
            {{end}}
            {{$t = print $t2 .Value.ticketID}}
            {{if ge (toInt .Value.resp) 1}} {{$pM = .Value.respArg.Username}} {{else}} {{$pM = "Nobody"}} {{end}}
            {{if or (eq (toInt .Value.alert) 3) (eq (toInt .Value.pos) 3)}} {{$timed = "0"}}
            {{else}}
                {{if eq (toInt .Value.alert) 1}} {{$timed = humanizeDurationHours ((.Value.duration).Sub currentTime)}}
                {{else if eq (toInt .Value.alert) 2}} {{$timed = humanizeDurationMinutes ((.Value.duration).Sub currentTime)}}
                {{end}}
            {{end}}
            {{$s1 = $creator.Username}}{{$s2 = $createdAt}}{{$s3 = $est}}{{$s4 = $pM}}{{$s5 = $timed}}
        {{end}}
    {{end}}
    {{$fields = cslice
        (sdict "name" "Creator" "value" $s1 "inline" true)
        (sdict "name" "Created At" "value" $s2 "inline" true)
        (sdict "name" "Status" "value" $s3 "inline" true)
        (sdict "name" "MOD" "value" $s4 "inline" true)
        (sdict "name" "AutoDel" "value" $s5 "inline" true)}}
    {{if eq $d 1}} {{sendMessage nil $ME}}
    {{else if eq $d 2}}
        {{$embed = cembed "title" $t "fields" $fields "color" $c "footer" (sdict "text" "Oldest 🎟️")}} {{$out := sendMessageRetID nil $embed}}
        {{if .IsPremium}} {{addMessageReactions nil $out "◀️" "▶️"}} {{end}}
    {{end}}
{{end}}
