{{/*
    Name: premiumPageUp.cc.lua
    This command manages the pagination of certain embeds

    You only need this if you are premium

    Dont change anything

    Trigger: Reaction with "Added Reactions Only" option
/*}}

{{/*ACTUAL CODE! DONT TOUCH*/}}
{{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}} {{$ticketOpen := $setup.ticketOpen}}{{$ticketClose := $setup.ticketClose}}{{$ticketSolving := $setup.ticketSolving}}
{{$emoji := .Reaction.Emoji.Name}}{{$t2 := "Ticket ID: "}}{{$RM := .ReactionMessage}}{{$isTE := false}}{{$estado := ""}}{{$printmod := ""}}{{$embed := ""}}{{$timed := ""}}{{$fields := ""}}{{$t := ""}}{{$NT := false}}{{$OT := false}}{{$pos := 0}}{{$list := cslice}}{{$bubbles := sdict}}{{$footer := "🎟️"}}{{$c := false}}{{$id := ""}}{{$a := false}}{{$cL := 0}}
{{if .IsPremium}}
    {{with and (eq $RM.Author.ID 204255221017214977) $RM.Embeds}}
        {{$eID := index . 0}}
        {{if and (reFind `Ticket ID: \d+` $eID.Title) $eID.Footer}}
            {{if reFind `🎟️` $eID.Footer.Text}}
                {{$isTE = true}} {{$id = reFind `\d+` $eID.Title}}
            {{end}}
        {{end}}
    {{end}}
    {{if $isTE}}
    {{$eC := index $RM.Embeds 0}}
        {{if eq $emoji "▶️"}}
            {{deleteMessageReaction nil $RM.ID .User.ID "▶️"}}
            {{if not (reFind `Newest 🎟️` $eC.Footer.Text)}}
                {{with (dbGet (add (toInt $id) 1) "ticket").Value}}
                    {{range dbTopEntries "ticket" 1 0}} {{if eq (toInt .Value.ticketID) (add (toInt $id) 1)}} {{$footer = "Newest 🎟️"}} {{end}} {{end}}
                    {{$createdAt := .ctime.Format "1 _2 2006 15:04 UTC"}}
                    {{if eq (toInt .pos) 1}} {{$estado = $ticketOpen}}
                    {{else if eq (toInt .pos) 2}} {{$estado = $ticketSolving}}
                    {{else if eq (toInt .pos) 3}} {{$estado = $ticketClose}}
                    {{end}}
                    {{$t = print $t2 .ticketID}}
                    {{if ge (toInt .resp) 1}} {{$printmod = .respArg.Username}}
                    {{else}} {{$printmod = "Nobody"}}
                    {{end}}
                    {{if or (eq (toInt .alert) 3) (eq (toInt .pos) 3)}} {{$timed = "0"}}
                    {{else}}
                        {{if eq (toInt .alert) 1}} {{$timed = humanizeDurationHours ((.duration).Sub currentTime)}}
                        {{else if eq (toInt .alert) 2}} {{$timed = humanizeDurationMinutes ((.duration).Sub currentTime)}}
                        {{end}}
                    {{end}}
                    {{$fields = (cslice
                        (sdict "name" "Creator" "value" .creator.Username "inline" true)
                        (sdict "name" "Created At" "value" $createdAt "inline" true)
                        (sdict "name" "Status" "value" $estado "inline" true)
                        (sdict "name" "MOD" "value" $printmod "inline" true)
                        (sdict "name" "AutoDel" "value" $timed "inline" true)
                    )}}
                    {{$embed = cembed "title" $t "fields" $fields "color" 3066993 "footer" (sdict "text" $footer)}}
                    {{editMessage nil $RM.ID $embed}}
                {{else}}
                    {{$newid := add (toInt $id) 1}}
                    {{$fill := dbTopEntries "ticket" 100 0}}
                    {{range $fill}} {{- $list = $list.Append (toInt .Value.ticketID) -}} {{end}}
                    {{if eq (len $fill) 100}} {{$c = true}} {{end}} {{$cL = index $list (sub (len $list) 1)}} {{if lt $newid $cL}} {{$a = true}} {{end}}
                    {{if and $a $c}}
                        {{$fill2 := dbTopEntries "ticket" 100 100}}
                        {{range $fill2}} {{- $list = $list.Append (toInt .Value.ticketID) -}} {{end}}
                        {{if eq (len $fill2) 100}} {{$c = true}} {{else}} {{$c = false}} {{end}} {{$cL = index $list (sub (len $list) 1)}} {{if lt $newid $cL}} {{$a = true}} {{else}} {{$a = false}} {{end}}
                    {{end}}
                    {{if and $a $c}}
                        {{$fill3 := dbTopEntries "ticket" 100 200}}
                        {{range $fill3}} {{- $list = $list.Append (toInt .Value.ticketID) -}} {{end}}
                        {{if eq (len $fill3) 100}} {{$c = true}} {{else}} {{$c = false}} {{end}} {{$cL = index $list (sub (len $list) 1)}} {{if lt $newid $cL}} {{$a = true}} {{else}} {{$a = false}} {{end}}
                    {{end}}
                    {{if and $a $c}}
                        {{$fill4 := dbTopEntries "ticket" 100 300}}
                        {{range $fill4}} {{- $list = $list.Append (toInt .Value.ticketID) -}} {{end}}
                        {{if eq (len $fill4) 100}} {{$c = true}} {{else}} {{$c = false}} {{end}} {{$cL = index $list (sub (len $list) 1)}} {{if lt $newid $cL}} {{$a = true}} {{else}} {{$a = false}} {{end}}
                    {{end}}
                    {{if and $a $c}}
                        {{$fill5 := dbTopEntries "ticket" 100 400}}
                        {{range $fill5}} {{$list = $list.Append (toInt .Value.ticketID)}} {{end}}
                        {{if eq (len $fill5) 100}} {{$c = true}} {{else}} {{$c = false}} {{end}} {{$cL = index $list (sub (len $list) 1)}} {{if lt $newid $cL}} {{$a = true}} {{else}} {{$a = false}} {{end}}
                    {{end}}
                    {{if and $a $c}}
                        {{$fill6 := dbTopEntries "ticket" 100 500}}
                        {{range $fill6}} {{- $list = $list.Append (toInt .Value.ticketID) -}} {{end}}
                    {{end}}
                    {{$list = $list.Append $newid}}
                    {{range $k, $v := $list}} {{- $bubbles.Set (str $k) $v -}} {{end}}
                    {{range $i := seq 0 (sub (len $bubbles) 1)}}
                        {{- range $j := seq 0 (sub (sub (len $bubbles) $i) 1) -}}
                            {{- if gt ($bubbles.Get (str $j) ) ($bubbles.Get (str (add $j 1) ) ) -}}
                                {{- $x := $bubbles.Get (str $j) -}} {{- $y := $bubbles.Get (str (add $j 1)) -}}
                                {{- $bubbles.Set (str $j) $y -}} {{- $bubbles.Set (str (add $j 1) ) $x -}}
                            {{- end -}}
                        {{- end -}}
                    {{end}}
                    {{range $k, $v := $bubbles}}
                        {{- if eq $v $newid -}} {{- $pos = $k -}}  {{- end -}}
                    {{end}}
                    {{if or (eq $newid (toInt ($bubbles.Get (str (sub (len $bubbles) 1))))) (eq $newid (toInt ($bubbles.Get "0")))}}
                    {{else}}
                        {{$nID := $bubbles.Get (str (add $pos 1))}}
                        {{range dbTopEntries "ticket" 1 0}} {{if eq (toInt .Value.ticketID) (toInt $nID)}} {{$footer = "Newest 🎟️"}} {{end}} {{end}}
                        {{$Value := (dbGet (toInt $nID) "ticket").Value}}
                        {{$creator := $Value.creator}}
                        {{$createdAt := $Value.ctime.Format "1 _2 2006 15:04 UTC"}}
                        {{if eq (toInt $Value.pos) 1}} {{$estado = $ticketOpen}}
                        {{else if eq (toInt $Value.pos) 2}} {{$estado = $ticketSolving}}
                        {{else if eq (toInt $Value.pos) 3}} {{$estado = $ticketClose}}
                        {{end}}
                        {{$t = print $t2 $Value.ticketID}}
                        {{if ge (toInt $Value.resp) 1}} {{$printmod = $Value.respArg.Username}}
                        {{else}} {{$printmod = "Nobody"}}
                        {{end}}
                        {{if or (eq (toInt $Value.alert) 3) (eq (toInt $Value.pos) 3)}} {{$timed = "0"}}
                        {{else}}
                            {{if eq (toInt $Value.alert) 1}} {{$timed = humanizeDurationHours (($Value.duration).Sub currentTime)}}
                            {{else if eq (toInt $Value.alert) 2}} {{$timed = humanizeDurationMinutes (($Value.duration).Sub currentTime)}}
                            {{end}}
                        {{end}}
                        {{$fields = (cslice
                            (sdict "name" "Creator" "value" $creator.Username "inline" true)
                            (sdict "name" "Created At" "value" $createdAt "inline" true)
                            (sdict "name" "Status" "value" $estado "inline" true)
                            (sdict "name" "MOD" "value" $printmod "inline" true)
                            (sdict "name" "AutoDel" "value" $timed "inline" true)
                        )}}
                        {{$embed = cembed "title" $t "fields" $fields "color" 3066993 "footer" (sdict "text" $footer)}}
                        {{editMessage nil $RM.ID $embed}}
                    {{- end -}}
                {{end}}
            {{end}}
        {{end}}
    {{end}}
{{end}}
