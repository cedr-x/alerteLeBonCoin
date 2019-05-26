# alerteLeBonCoin
Notifications par mail de nouvelles annonces pour une recherche donnée  

# Description
Ce script (bash) appelé par cron envoie un mail avec la liste des articles répondant à la recherche si un nouvel article est disponible depuis la dernière execution du script.  
C'est exactement ce que propose Le Bon Coin avec le systèmes d'alertes, mais schedulé toutes les heures permet d'être le premier offrant :)  

La conf se fait dans le script lui même (mail from/ to, ... )  
L'argument de recherche est donné en argument (peut être configuré également en dur dans le script)  
