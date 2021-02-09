# Notes

## Démarrage

`docker-compose up`: lance le docker ***db***
`docker-compose exec db sh` : se connecte au docker en SHELL
`psql -U root -h localhost app` : se connecte à la base ***app*** via l'utilisateur ***root*** en TCP

## Hiérarchie SQL d'une base POSTGRES

database -> schema -> table -> row

## Commandes psql utiles

`\?` Affiche les commandes disponibles
`\l` Affiche la liste des databases
`\dn` Affiche la liste des schémas
`\dt` Affiche l'ensemble des tables

## Troubleshooting

- On utilise les `"` pour échapper les mots réservés comme `"user"` et on utilise les `'` pour les chaînes de caractères.