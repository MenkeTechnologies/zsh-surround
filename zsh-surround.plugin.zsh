#automatically add closing punct
surround(){
    if [[ $ZPWR_SURROUND != false ]]; then
        if [[ $ZPWR_SEND_KEYS_FULL == false ]]; then
            if [[ -f "$ZPWR_LOCK_FILE" ]]; then
                if cat $ZPWR_LOCK_FILE | grep -q $$; then
                    zle .self-insert
                    return 0
                fi
            fi
        fi

        next=$((CURSOR+1))

        local char=${BUFFER[$CURSOR]}
        local nextChar=${BUFFER[$next]}
        #echo char is $char >> $LOGFILE
        #echo nextChar is $nextChar >> $LOGFILE

        count=$(print -r -- "$BUFFER" | fgrep -o "$KEYS" | wc -l)

        #TODO = only if next char is space or
        #end of line then insert quotes
        case "$nextChar" in
            [a-zA-Z0-9]*)
                BUFFER="$LBUFFER$KEYS$RBUFFER"
                zle .vi-forward-char
                return 0
                ;;
        *)
                ;;
        esac

        case "$KEYS" in
            '"')
                if (( $count % 2 == 1 )); then
                    BUFFER="$LBUFFER$KEYS$RBUFFER"
                    #echo odd Char is $count >> $LOGFILE
                    zle .vi-forward-char
                    return 0
                fi
                BUFFER="$LBUFFER\"\"$RBUFFER"
                ;;
            '`')
                if (( $count % 2 == 1 )); then
                    BUFFER="$LBUFFER$KEYS$RBUFFER"
                    #echo odd Char is $count >> $LOGFILE
                    zle .vi-forward-char
                    return 0
                fi
                BUFFER="$LBUFFER\`\`$RBUFFER"
                ;;
            "'")
                if (( $count % 2 == 1 )); then
                    BUFFER="$LBUFFER$KEYS$RBUFFER"
                    #echo odd Char is $count >> $LOGFILE
                    zle .vi-forward-char
                    return 0
                fi
                BUFFER="$LBUFFER''$RBUFFER"
                ;;
            '{')
            BUFFER="$LBUFFER{}$RBUFFER"
                ;;
            "[")
            BUFFER="$LBUFFER"'[]'"$RBUFFER"
                ;;
            "(")
            BUFFER="$LBUFFER()$RBUFFER"
                ;;
        *)
            ;;
        esac
        zle .vi-forward-char
    else
        zle .self-insert

    fi
}


#delete the next matching closing punct
deleteMatching(){
    local next=$((CURSOR+1))
    local char=${BUFFER[$CURSOR]}
    local nextChar=${BUFFER[$next]}

    #echo char is $char >> $LOGFILE
    #echo nextChar is $nextChar >> $LOGFILE

    case "$char" in
        '"')
            if [[ "$nextChar" == "$char" ]]; then
                BUFFER="$LBUFFER${RBUFFER/$char/}"
            fi
            ;;
        '`')
            if [[ "$nextChar" == "$char" ]]; then
                BUFFER="$LBUFFER${RBUFFER/$char/}"
            fi
            ;;
        "'")
            if [[ "$nextChar" == "$char" ]]; then
                BUFFER="$LBUFFER${RBUFFER/$char/}"
            fi
            ;;
        '{')
            if [[ "$nextChar" == "}" ]]; then
                BUFFER="$LBUFFER${RBUFFER/\}/}"
            fi
            ;;
        "[")
            if [[ "$nextChar" == "]" ]]; then
                BUFFER="$LBUFFER${RBUFFER/\]/}"
            fi
            ;;
        "(")
            if [[ "$nextChar" == ")" ]]; then
              BUFFER="$LBUFFER${RBUFFER/)/}"
            fi
            ;;
        *)
            ;;
    esac

    zle .vi-backward-delete-char

}


zle -N surround
zle -N deleteMatching

bindkey -M viins '"' surround
bindkey -M viins "'" surround
bindkey -M viins '`' surround
bindkey -M viins "(" surround
bindkey -M viins "[" surround
bindkey -M viins "{" surround
bindkey -M viins "^?" deleteMatching

