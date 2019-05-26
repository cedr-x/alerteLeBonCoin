#!/bin/bash
MAIL_FROM=noreply@domain.com
MAIL_TO=youraddr@domain.com
SUBJECT="[Alerte Le Bon Coin] $1"

################ LOCATION
#IDF
#WHERE='{"locations":[{"locationType":"region","label":"Ile-de-France","region_id":"12"}]}'
#78
#WHERE='{"locations":[{"locationType":"department","label":"Yvelines","department_id":"78","region_id":"12"}]}'
#COMMUNES VOISINNES
WHERE='{"locations":[{"locationType":"city","zipcode":"78690","label":"Toutes les communes 78690"},{"locationType":"city","zipcode":"78720","label":"Toutes les communes 78720"},{"locationType":"city","zipcode":"78180","label":"Toutes les communes 78180"},{"locationType":"city","zipcode":"78120","label":"Toutes les communes 78120"},{"locationType":"city","zipcode":"78460","label":"Toutes les communes 78460"},{"locationType":"city","zipcode":"78000","label":"Toutes les communes 78000"},{"locationType":"city","zipcode":"78610","label":"Toutes les communes 78610"},{"locationType":"city","zipcode":"78310","label":"Toutes les communes 78310"},{"locationType":"city","zipcode":"78320","label":"Toutes les communes 78320"}]}'

################# RANGES: differents filtres de recherches
# limite haute et mini : RANGES='"price": {"max":900,"min":200}'
# pas de limite de prix: RANGES='"price": {}'
RANGES='"price": {"max": 50}'

################# KEYWORDS
# Recherche boolean : # WHAT='{"text":"xps *9360 OR xps *9370 OR xps *9380"}'
# Recheche seulement dans le sujet: ajouter "type":"subject" au payload keyworks :  #WHAT='{"text":"vinyle*","type":"subject"}'
# Recheche simple (passé en parametre) :
WHAT='{"text":"'$1'"}'

#QS='{"filters":{"category":{"id":"15"},"enums":{"ad_type":["offer"]},"keywords":{"text":"'$WHAT'"},"location":'$WHERE',"ranges":{'${RANGES}'}},"limit":35,"limit_alu":3,"store_id":"11058896"}'
#QS='{"limit":35,"limit_alu":3,"filters":{"category":{},"enums":{"ad_type":["offer"]},"location":{"locations":[{"locationType":"region","label":"Ile-de-France","region_id":"12"}]},"keywords":{"text":"Dell  5379"},"ranges":{}},"store_id":"11058896"}'
QS='{"filters":{"category":{},"enums":{"ad_type":["offer"]},"keywords":'$WHAT',"location":'$WHERE',"ranges":{'${RANGES}'}},"limit":100,"limit_alu":3}'

function getLBC {
  API=https://api.leboncoin.fr/finder/search
  QS="$1"
  TMPQS=$( echo "$QS"|md5sum | cut -c 1-32)
  echo "$QS" > /tmp/LBC.${TMPQS}.json

  curl -s  --data "$QS" -X POST $API | tee /tmp/lastCurl | jq '.ads[]|.subject, .index_date, .url, .price[], .images.thumb_url, .body, .location.city_label' | tr -d \" > /tmp/LBC.${TMPQS}.new
  touch /tmp/LBC.${TMPQS}.old
  diff /tmp/LBC.${TMPQS}.new /tmp/LBC.${TMPQS}.old | grep '^< ' || return 1
  cat /tmp/LBC.${TMPQS}.new > /tmp/LBC.${TMPQS}.old
}

function mailLBC {
  # Formate le JSON {sujet, date, url, prix, image, description, localisation} en un bon gros tableau dans un mail.
  (
    echo -e  'From: <'${MAIL_FROM}'>\nTo: <'$MAIL_TO'>\nSubject: '${SUBJECT}'\nContent-type: text/html; charset="UTF-8"\n\n'
    awk 'function OUT(s,d,u,p,i,b,l) \
         {if(d) print "<A HREF="u">"s"</A><BR><font size=1>"d"<BR>"l"</font><BR><table border=0><tr><td><IMG SRC="i"></td><td><font size=1>"b"</font><br><b>"p " €</b></td></tr></table><HR><BR>" } \
         {nr=(NR%7);if(nr == 1){OUT(s,d,u,p,i,b,l);s=$0 };if(nr==2){d=$0};if(nr==3){u=$0};if(nr==4){p=$0};if(nr==5){i=$0};if(nr==6){b=$0};if(nr==0){l=$0}} \
         END {  OUT(s,d,u,p,i,b,l) }'   /tmp/LBC.${TMPQS}.old
  ) | sed 's/\\n/<br>/g' | sendmail ${MAIL_TO}
}

getLBC "$QS" && mailLBC
