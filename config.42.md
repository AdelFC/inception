# Configuration pour l'école 42

Ce fichier liste tous les changements à effectuer pour migrer le projet de l'environnement de développement (Ubuntu à domicile) vers l'environnement de l'école (VM Debian).

## Variables d'environnement - srcs/.env

Modifier uniquement la variable `LOGIN` :

```bash
LOGIN=afodil-c
```

Toutes les autres variables restent identiques (domaine, mots de passe, etc.).

## Fichiers à modifier

### 1. srcs/docker-compose.yml

Remplacer les chemins des volumes (lignes 45-55) :

**Avant (domicile) :**
```yaml
volumes:
  mariadb_data:
    driver_opts:
      type: none
      o: bind
      device: /home/afc/Desktop/42/inception/srcs/volumes/mariadb_data

  wordpress_data:
    driver_opts:
      type: none
      o: bind
      device: /home/afc/Desktop/42/inception/srcs/volumes/wordpress_data
```

**Après (école) :**
```yaml
volumes:
  mariadb_data:
    driver_opts:
      type: none
      o: bind
      device: /home/afodil-c/data/mariadb

  wordpress_data:
    driver_opts:
      type: none
      o: bind
      device: /home/afodil-c/data/wordpress
```

### 2. Makefile

Modifier la variable `DATA_PATH` (ligne 14) :

**Avant (domicile) :**
```makefile
DATA_PATH	= srcs/volumes
```

**Après (école) :**
```makefile
DATA_PATH	= /home/afodil-c/data
```

Et adapter les cibles `up` et `fclean` (lignes 27 et 51) :

**Avant (domicile) :**
```makefile
up:
	@mkdir -p $(DATA_PATH)/mariadb_data $(DATA_PATH)/wordpress_data

fclean: clean
	@sudo rm -rf $(DATA_PATH)/mariadb_data/* $(DATA_PATH)/wordpress_data/*
```

**Après (école) :**
```makefile
up:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

fclean: clean
	@sudo rm -rf $(DATA_PATH)/mariadb/* $(DATA_PATH)/wordpress/*
```

## Résumé des changements

| Fichier | Ligne(s) | Changement |
|---------|----------|------------|
| `srcs/.env` | 1 | `LOGIN=afc` → `LOGIN=afodil-c` |
| `srcs/docker-compose.yml` | 49 | `/home/afc/Desktop/42/inception/srcs/volumes/mariadb_data` → `/home/afodil-c/data/mariadb` |
| `srcs/docker-compose.yml` | 55 | `/home/afc/Desktop/42/inception/srcs/volumes/wordpress_data` → `/home/afodil-c/data/wordpress` |
| `Makefile` | 14 | `DATA_PATH = srcs/volumes` → `DATA_PATH = /home/afodil-c/data` |
| `Makefile` | 27 | `mariadb_data wordpress_data` → `mariadb wordpress` |
| `Makefile` | 51 | `mariadb_data/* wordpress_data/*` → `mariadb/* wordpress/*` |

## Commandes à exécuter après migration

1. Créer les répertoires de données :
```bash
mkdir -p /home/afodil-c/data/mariadb /home/afodil-c/data/wordpress
```

2. Lancer le projet :
```bash
make
```

## Notes importantes

- **Domaine** : Le domaine `afodil-c.42.fr` est déjà correct dans le `.env`, pas besoin de le changer
- **/etc/hosts** : Penser à ajouter `127.0.0.1 afodil-c.42.fr` dans `/etc/hosts` sur la VM de l'école
- **Permissions** : Les volumes à l'école doivent être dans `/home/afodil-c/data` comme spécifié dans le sujet
- **Docker** : Vérifier la version de docker-compose sur la VM de l'école (utilise `docker-compose` v1 comme à domicile)

## Retour en arrière (domicile)

Pour revenir à la configuration de développement à domicile, inverser tous les changements ci-dessus.
