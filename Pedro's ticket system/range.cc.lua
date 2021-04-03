{{/*
    Name: range.cc.lua
    Dont change anything!

    This is the "Range CC" command.

    Trigger: None
/*}}

{{/* ACTUAL CODE! DONT TOUCH */}}
{{if .ExecData.test}}
    {{execCC .ExecData.sch nil 1 (sdict "test" "test" "id" .ExecData.id "thisCC" .ExecData.thisCC)}}
{{else}}
    {{$tn := .ExecData.tn}}
    {{$key := print $tn "adicionados"}}
    {{$master := sdict (dbGet (toInt $tn) "ticket").Value}}
    {{$counter := toInt $master.ticketCounter}}
    {{$entries := dbTopEntries $key 15 0}}
    {{$desc := ""}}
    {{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
    {{$SchedueledCCID := toInt $setup.SchedueledCCID}}
    {{$TO := $setup.ticketOpen}}{{$TS := $setup.ticketSolving}}{{$TC := $setup.ticketClose}}
    {{$masterChannel := toInt $setup.masterTicketChannelID}}
    {{$displayMSGID := toInt $setup.displayMSGID}}
    {{$strCID := str .Channel.ID}}
    {{if .ExecData.um}}
        {{if ge $counter 1}}
            {{if le (len $entries) 5}}
                {{range $entries}} {{- $s := execAdmin "ticket removeuser" .User.ID -}} {{end}}
                {{$master.Set "rodando" 0}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{with .ExecData.msgID}} {{editMessage nil . (cembed "description" "All users have been removed from this ticket." "color" 1146986)}}
                {{else}} {{sendMessage nil (cembed "description" "All users have been removed from this ticket." "color" 1146986)}}
                {{end}}
            {{else}}
                {{$msgID := sendMessageRetID nil (cembed "description" "More than 5 users were on this ticket. Wait until you can make any action!" "color" 15105570)}}
                {{deleteResponse 5}}
                {{$entries = dbTopEntries $key 5 0}}
                {{range $entries}} {{- $s := execAdmin "ticket removeuser" .User.ID -}} {{end}}
                {{$master.Set "rodando" 1}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{execCC .CCID nil 5 (sdict "tn" $tn "um" 1 "msgID" $msgID)}}
            {{end}}
        {{end}}
    {{else if .ExecData.dois}}
        {{if ge $counter 1}}
            {{if le (len $entries) 5}}
                {{range $entries}} {{- $s := execAdmin "ticket adduser" .User.ID -}} {{end}}
                {{$master.Set "rodando" 0}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{with .ExecData.msgID}} {{editMessage nil . (cembed "description" "All users have been added again to this ticket." "color" 1146986)}}
                {{else}} {{sendMessage nil (cembed "description" "All users have been added again to this ticket." "color" 1146986)}}
                {{end}}
            {{else}}
                {{$msgID := sendMessageRetID nil (cembed "description" "More than 5 users were on this ticket. Still adding users." "color" 15105570)}}
                {{deleteResponse 5}}
                {{$entries = dbTopEntries $key 5 0}}
                {{range $entries}} {{- $s := execAdmin "ticket adduser" .User.ID -}} {{end}}
                {{$master.Set "rodando" 1}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{execCC .CCID nil 5 (sdict "tn" $tn "dois" 2 "msgID" $msgID)}}
            {{end}}
        {{end}}
    {{else if .ExecData.tres}}
        {{if ge $counter 1}}
            {{if le (len $entries) 5}}
                {{- range $entries -}}
                    {{- dbDel .User.ID $key -}}
                    {{- $s := execAdmin "ticket removeuser" .User.ID -}}
                {{- end -}}
                {{dbDel (toInt $tn) "ticket"}}
                {{with .ExecData.msgID}}
                    {{editMessage nil . (cembed "description" "All users deleted. Ticket is being deleted." "color" 1146986)}}
                {{else}}
                    {{sendMessage nil (cembed "description" "All users deleted. Ticket is being deleted." "color" 1146986)}}
                {{end}}
                {{$s := execAdmin "ticket close" ""}}
            {{else}}
                {{$msgID := sendMessageRetID nil (cembed "description" "More than 5 users were on this ticket. Still deleting them." "color" 15105570)}}
                {{deleteResponse 5}}
                {{$entries = dbTopEntries $key 4 0}}
                {{- range $entries -}}
                    {{- dbDel .User.ID $key -}}
                    {{- $s := execAdmin "ticket removeuser" .User.ID -}}
                {{- end -}}
                {{execCC .CCID nil 5 (sdict "tn" $tn "tres" 3 "msgID" $msgID)}}
            {{end}}
        {{else}}
            {{sendMessage nil (cembed "description" "Ticket is being deleted." "color" 1146986)}}
            {{dbDel (toInt $tn) "ticket"}}
            {{$s := execAdmin "ticket close" ""}}
            {{$map := sdict}}
            {{with (dbGet 0 "ticketDisplay").Value}} {{$map = sdict .}} {{$map.Del (str $master.channelID)}} {{dbSet 0 "ticketDisplay" $map}} {{end}}
            {{$s := sendTemplate nil "display" (sdict "ID" $strCID "Arg" $TC "Master" $masterChannel "MsgID" $displayMSGID)}}
            {{dbSet 0 "ticketDisplay" $map}}
        {{end}}
    {{end}}
    {{if .ExecData.continueSch}}
        {{$time := currentTime}}
        {{$Delay := toInt .ExecData.delay}}
        {{$realDelay := mult $Delay 3600}}
        {{if eq (toInt .ExecData.AoD) 1}}
            {{$master.Set "duration" ($time.Add (toDuration (print (str $Delay) "h30m")))}}
            {{$master.Set "alert" 2}}
            {{dbSet (toInt $tn) "ticket" $master}}
            {{scheduleUniqueCC $SchedueledCCID nil $realDelay $tn (sdict "alert" 2)}}
        {{else}}
            {{$master.Set "duration" ($time.Add (toDuration (print (str $Delay) "h")))}}
            {{$3HoursAlert := sub $realDelay 10800}}
            {{$master.Set "alert" 1}}
            {{dbSet (toInt $tn) "ticket" $master}}
            {{scheduleUniqueCC $SchedueledCCID nil $3HoursAlert $tn (sdict "alert" 1)}}
        {{end}}
    {{end}}
{{end}}

{{define "display"}}
{{$arg := .TemplateArgs.Arg}}
{{$ID := str .TemplateArgs.ID}}
{{with (dbGet 0 "ticketDisplay").Value}} {{with sdict .}} {{if .Get $ID}} {{.Set $ID $arg}} {{dbSet 0 "ticketDisplay" .}} {{end}} {{end}} {{end}}
{{$arr := cslice}}
{{with (dbGet 0 "ticketDisplay").Value}}
    {{$map := sdict .}}
    {{range $k, $v := $map}} {{- $arr = $arr.Append (cslice $v $k) -}} {{end}}
    {{$len := len $arr}}
    {{range seq 0 $len}}
        {{- $min := . -}}
        {{- range seq (add . 1) $len -}} {{- if gt (index $arr $min 1) (index $arr . 1) }} {{ $min = . }} {{ end -}} {{- end -}}
        {{- if ne $min . -}} {{- $ := index $arr . -}} {{- $arr.Set . (index $arr $min) -}} {{- $arr.Set $min $ -}} {{- end -}}
    {{end}}
{{end}}
{{$desc := printf "%s - %-10s\n" "**TicketID**" "**Status**"}}
{{range $arr}} {{- $desc = print $desc (printf (print "<#%d> - `%-" (index . 0 | len) "s`\n") (index . 1 | toInt) (index . 0)) -}} {{end}}
{{editMessage .TemplateArgs.Master .TemplateArgs.MsgID (cembed "title" "Tickets Display" "color" (randInt 16777216) "description" $desc)}}
{{end}}
