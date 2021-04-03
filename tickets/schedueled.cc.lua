{{/*
    Name: schedueled.cc.lua
    This command manages the delay until tickets get deleted for inactivity.

    This is the "Schedueled CC" command.

    Dont change anything!

    Trigger: None
/*}}


{{/* ACTUAL CODE! DONT TOUCH */}}
{{if .ExecData.test}}
    {{execCC .ExecData.thisCC nil 1 (sdict "id" .ExecData.id)}}
{{else}}
    {{$setup := sdict}} {{with (dbGet 0 "ticket_cfg").Value}} {{$setup = sdict .}} {{end}}
    {{$CCID := toInt $setup.CCID}}
    {{$alert := .ExecData.alert}}
    {{$tn := reFind `\d+` .Channel.Name}}
    {{if $tn}}
        {{$master := sdict (dbGet (toInt $tn) "ticket").Value}}
        {{$AoD := $master.Value.AoD}}

        {{/* START */}}
        {{if not (eq (toInt $master.pos) 3)}}
            {{if (eq $alert 1)}}
                {{$master.Set "duration" (currentTime.Add (toDuration "3h"))}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{$embed := cembed "description" "This ticket will be closed in 3 hours because of inactivity!" "title" "WARNING!"}}
                {{$content := print "The ticket " $tn " will be closed soon!\n\n" mentionEveryone}}
                {{sendMessageNoEscape nil (complexMessage "content" $content "embed" $embed)}}
                {{scheduleUniqueCC .CCID nil 9000 $tn (sdict "alert" 2)}}
            {{else if eq $alert 2}}
                {{$master.Set "duration" (currentTime.Add (toDuration "30m"))}}
                {{$master.Set "alert" 2}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{$embed := cembed "description" "This ticket will be closed in 30 minutes because of inactivity!" "title" "WARNING!"}}
                {{$content := print "The ticket " $tn " is about to be closed!\n\n" mentionEveryone}}
                {{sendMessageNoEscape nil (complexMessage "content" $content "embed" $embed)}}
                {{scheduleUniqueCC .CCID nil 1800 $tn (sdict "alert" 3)}}
            {{else if eq $alert 3}}
                {{$master.Set "duration" 0}}
                {{$master.Set "alert" 3}}
                {{dbSet (toInt $tn) "ticket" $master}}
                {{sendMessage nil (cembed "description" "This ticket is getting closed because of inactivity!" "color" 15158332)}}
                {{execCC $CCID nil 5 (sdict "tn" $tn "tres" 3)}}
            {{end}}
        {{end}}
    {{end}}
{{end}}
