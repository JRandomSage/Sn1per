# FULLPORTONLY MODE
if [[ "$MODE" = "fullportonly" ]]; then

  if [[ "$REPORT" = "1" ]]; then
    args="-t $TARGET"
    if [[ ! -z "$WORKSPACE" ]]; then
      args="$args -w $WORKSPACE"
      LOOT_DIR=$INSTALL_DIR/loot/workspace/$WORKSPACE
      echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR [$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
      mkdir -p $LOOT_DIR 2> /dev/null
      mkdir $LOOT_DIR/domains 2> /dev/null
      mkdir $LOOT_DIR/screenshots 2> /dev/null
      mkdir $LOOT_DIR/nmap 2> /dev/null
      mkdir $LOOT_DIR/notes 2> /dev/null
      mkdir $LOOT_DIR/reports 2> /dev/null
      mkdir $LOOT_DIR/scans 2> /dev/null
      mkdir $LOOT_DIR/output 2> /dev/null
    fi
    args="$args --noreport -m fullportonly" 
    echo "$TARGET $MODE `date +"%Y-%m-%d %H:%M"`" 2> /dev/null >> $LOOT_DIR/scans/tasks.txt 2> /dev/null
    echo "sniper -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/running-$TARGET-$MODE.txt
    ls -lh $LOOT_DIR/scans/running-*.txt 2> /dev/null | wc -l 2> /dev/null > $LOOT_DIR/scans/tasks-running.txt
    sniper $args | tee $LOOT_DIR/output/sniper-$TARGET-$MODE-`date +"%Y%m%d%H%M"`.txt 2>&1
    exit
  fi

  logo
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[xerosecurity.com] •?((¯°·._.• Started Sn1per scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
    echo "[xerosecurity.com] •?((¯°·._.• Started Sn1per scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications.txt
  fi
  echo "$TARGET" >> $LOOT_DIR/domains/targets.txt
  if [[ -z "$PORT" ]]; then
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo -e "$OKRED PERFORMING TCP PORT SCAN $RESET"
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    nmap $NMAP_OPTIONS --script=/usr/share/nmap/scripts/vulners -oX $LOOT_DIR/nmap/nmap-$TARGET.xml -p $FULL_PORTSCAN_PORTS $TARGET | tee $LOOT_DIR/nmap/nmap-$TARGET
    sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET.txt 2> /dev/null
    rm -f $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null
    xsltproc $INSTALL_DIR/bin/nmap-bootstrap.xsl $LOOT_DIR/nmap/nmap-$TARGET.xml -o $LOOT_DIR/nmap/nmapreport-$TARGET.html 2> /dev/null
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo -e "$OKRED PERFORMING UDP PORT SCAN $RESET"
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    nmap -sU $NMAP_OPTIONS --script=/usr/share/nmap/scripts/vulners -oX $LOOT_DIR/nmap/nmap-$TARGET-udp.xml -p $DEFAULT_UDP_PORTS $TARGET 
    sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET-udp 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET-udp.txt 2> /dev/null
    rm -f $LOOT_DIR/nmap/nmap-$TARGET-udp 2> /dev/null
  else
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo -e "$OKRED PERFORMING TCP PORT SCAN $RESET"
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    nmap $NMAP_OPTIONS --script=/usr/share/nmap/scripts/vulners -p $PORT -oX $LOOT_DIR/nmap/nmap-$TARGET-tcp-port$PORT.xml $TARGET | tee $LOOT_DIR/nmap/nmap-$TARGET
    sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET.txt 2> /dev/null
    rm -f $LOOT_DIR/nmap/nmap-$TARGET 2> /dev/null
    xsltproc $INSTALL_DIR/bin/nmap-bootstrap.xsl $LOOT_DIR/nmap/nmap-$TARGET.xml -o $LOOT_DIR/nmap/nmapreport-$TARGET.html 2> /dev/null
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    echo -e "$OKRED PERFORMING UDP PORT SCAN $RESET"
    echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
    nmap -sU $NMAP_OPTIONS --script=/usr/share/nmap/scripts/vulners -p $PORT -Pn -oX $LOOT_DIR/nmap/nmap-$TARGET-udp-port$PORT.xml $TARGET | tee $LOOT_DIR/nmap/nmap-$TARGET-udp
    sed -r "s/</\&lh\;/g" $LOOT_DIR/nmap/nmap-$TARGET-udp 2> /dev/null > $LOOT_DIR/nmap/nmap-$TARGET-udp.txt 2> /dev/null
    rm -f $LOOT_DIR/nmap/nmap-$TARGET-udp 2> /dev/null
  fi
  source $INSTALL_DIR/modes/sc0pe.sh 
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo -e "$OKRED SCAN COMPLETE! $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[`date +"%Y-%m-%d](%H:%M)"`${RESET}x•"
  echo "$TARGET" >> $LOOT_DIR/scans/updated.txt
  mv $LOOT_DIR/scans/running-$TARGET-$MODE.txt $LOOT_DIR/scans/finished-$TARGET-$MODE.txt 2> /dev/null
  ls -lh $LOOT_DIR/scans/running-*.txt 2> /dev/null | wc -l 2> /dev/null > $LOOT_DIR/scans/tasks-running.txt

  HOST_UP=$(cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt 2> /dev/null | grep "host up" 2> /dev/null)
  if [[ ${#HOST_UP} -ge 2 ]]; then
    echo "$TARGET" >> $LOOT_DIR/nmap/livehosts-unsorted.txt 2> /dev/null
  fi
  sort -u $LOOT_DIR/nmap/livehosts-unsorted.txt 2> /dev/null > $LOOT_DIR/nmap/livehosts-sorted.txt 2> /dev/null

  mv -f $LOOT_DIR/nmap/ports-$TARGET.txt $LOOT_DIR/nmap/ports-$TARGET.old 2> /dev/null
  for PORT in `cat $LOOT_DIR/nmap/nmap-$TARGET.xml $LOOT_DIR/nmap/nmap-$TARGET-*.xml 2>/dev/null | egrep 'state="open"' | cut -d' ' -f3 | cut -d\" -f2 | sort -u | grep '[[:digit:]]'`; do
    echo "$PORT " >> $LOOT_DIR/nmap/ports-$TARGET.txt
  done

  diff $LOOT_DIR/nmap/ports-$TARGET.old $LOOT_DIR/nmap/ports-$TARGET.txt 2> /dev/null > $LOOT_DIR/nmap/ports-$TARGET.diff 2> /dev/null
  cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt 2>/dev/null | egrep "MAC Address:" | awk '{print $3 " " $4 " " $5 " " $6}' > $LOOT_DIR/nmap/macaddress-$TARGET.txt 2> /dev/null
  cat $LOOT_DIR/nmap/nmap-$TARGET.txt $LOOT_DIR/nmap/nmap-$TARGET-*.txt $LOOT_DIR/output/nmap-$TARGET-*.txt 2>/dev/null | egrep "OS details:|OS guesses:" | cut -d\: -f2 | sed 's/,//g' | head -c50 - > $LOOT_DIR/nmap/osfingerprint-$TARGET.txt 2> /dev/null
  
  if [[ "$SLACK_NOTIFICATIONS_NMAP" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET.txt"
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/nmap-$TARGET-udp.txt"
  fi

  if [[ "$SLACK_NOTIFICATIONS_NMAP_DIFF" == "1" ]] && [[ -s "$LOOT_DIR/nmap/ports-$TARGET.diff" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[xerosecurity.com] •?((¯°·._.• Port change detected on $TARGET (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
    /bin/bash "$INSTALL_DIR/bin/slack.sh" postfile "$LOOT_DIR/nmap/ports-$TARGET.diff"
    echo "[xerosecurity.com] •?((¯°·._.• Port change detected on $TARGET (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications.txt
    cat $LOOT_DIR/nmap/ports-$TARGET.diff 2> /dev/null | egrep "<|>" >> $LOOT_DIR/scans/notifications.txt 2> /dev/null 
  fi
  
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[xerosecurity.com] •?((¯°·._.• Finished Sn1per scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
    echo "[xerosecurity.com] •?((¯°·._.• Finished Sn1per scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications.txt
  fi
  loot
  exit
fi

if [[ "$MODE" = "port" ]]; then
  if [[ -z "$PORT" ]]; then
    echo -e "$OKRED + -- --=[Error: You need to enter a port number. $RESET"
    exit
  fi
fi
