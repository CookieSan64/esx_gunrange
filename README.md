# old_gunrange
Script de base : https://github.com/Oldarorn/old_gunrange
Ajoutez un stand de tir à votre serveur où vous pouvez entraîner votre objectif

## Informations

- 5 niveaux de difficulté (de facile à impossible)
- Vous pouvez choisir le nombre de cibles que vous souhaitez tirer (de 10 à 20)
- Vous pouvez obtenir 1 à 5 points de chaque cible, selon si vous êtes bon tireur.
- Les scores sont enregistrés dans un table SQL
- Vous pouvez configurer quelles armes seront autorisées à obtenir des points lors du tir (config.lua)
   
## Rrequirements

   - es_extended => https://github.com/ESX-Org/es_extended

## Installation

1. Installez old_gunrange dans votre dossier resources/[esx]
2. Ajoutez la table SQL
3. Ajoutez ceci dans votre server.cfg :
> ensure old_gunrange
