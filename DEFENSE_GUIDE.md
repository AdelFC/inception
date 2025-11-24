# Guide de Défense Inception

Ce document récapitule toutes les notions et commandes essentielles pour réussir la correction du projet Inception.

---

## Table des matières

1. [Préparation avant la défense](#préparation-avant-la-défense)
2. [Connaissances théoriques requises](#connaissances-théoriques-requises)
3. [Commandes à connaître](#commandes-à-connaître)
4. [Points de vérification de la scale](#points-de-vérification-de-la-scale)
5. [Checklist de défense](#checklist-de-défense)
6. [Questions fréquentes](#questions-fréquentes)

---

## Préparation avant la défense

### 1. Nettoyage complet du système Docker

```bash
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```

### 2. Vérifier la structure du projet

```bash
ls -la
# Doit montrer :
# - Makefile (à la racine)
# - srcs/ (contenant docker-compose.yml et .env)
# - srcs/requirements/ (nginx, wordpress, mariadb)
```

### 3. Vérifier /etc/hosts

```bash
cat /etc/hosts | grep afodil-c.42.fr
# Doit afficher : 127.0.0.1 afodil-c.42.fr
```

Si absent, ajouter :
```bash
sudo sh -c 'echo "127.0.0.1 afodil-c.42.fr" >> /etc/hosts'
```

### 4. Créer les répertoires de données

```bash
mkdir -p /home/afodil-c/data/mariadb /home/afodil-c/data/wordpress
```

---

## Connaissances théoriques requises

### Docker vs Virtual Machine

**Docker (Conteneurs)**
- Partage le noyau du système hôte
- Léger (quelques Mo)
- Démarrage rapide (secondes)
- Isolation au niveau processus
- Portable entre environnements

**VM (Machines virtuelles)**
- Émule un système complet avec son propre noyau
- Lourd (plusieurs Go)
- Démarrage lent (minutes)
- Isolation complète au niveau matériel
- Consomme plus de ressources

### Docker Compose vs Docker seul

**Docker seul**
- Gestion manuelle des conteneurs avec `docker run`
- Chaque conteneur doit être lancé individuellement
- Configuration via ligne de commande (verbose)

**Docker Compose**
- Orchestration multi-conteneurs
- Configuration déclarative (YAML)
- Lancement de toute l'infrastructure avec une seule commande
- Gestion des dépendances entre services
- Réseau automatique entre conteneurs

### Docker Network

**Pourquoi un réseau Docker ?**
- Permet la communication entre conteneurs
- Isolation des services
- Résolution DNS automatique (nom du service = hostname)
- Exemple : `wordpress` peut contacter `mariadb` par son nom

**Types de réseaux**
- **bridge** (par défaut) : réseau privé sur l'hôte
- **host** : partage le réseau de l'hôte (INTERDIT dans ce projet)
- **none** : aucun réseau

### TLS/SSL

**TLS (Transport Layer Security)**
- Protocole de chiffrement des communications
- Versions : TLSv1.2, TLSv1.3 (ce projet utilise TLSv1.3 uniquement)
- Certificat auto-signé : valide mais non reconnu par une autorité

**Pourquoi port 443 ?**
- Port standard pour HTTPS
- HTTP = port 80 (non sécurisé, INTERDIT ici)
- HTTPS = port 443 (sécurisé avec TLS)

### PID 1 et Entrypoints

**PID 1**
- Premier processus dans un conteneur
- Doit rester actif pour que le conteneur tourne
- Responsable de gérer les signaux (SIGTERM, SIGKILL)

**Bonnes pratiques**
- Lancer le service en foreground (`-F`, `daemon off`)
- Éviter les hacks (`tail -f`, `sleep infinity`, `while true`)
- Utiliser `exec` dans les scripts pour remplacer le shell par le processus principal

---

## Commandes à connaître

### Construction et lancement

```bash
# Lancer tout le projet
make

# Ou manuellement :
make build  # Construit les images
make up     # Démarre les conteneurs
```

### Inspection des conteneurs

```bash
# Voir les conteneurs en cours d'exécution
docker ps
docker-compose -f srcs/docker-compose.yml ps

# Logs d'un service
docker logs mariadb
docker logs wordpress
docker logs nginx

# Logs en temps réel
docker logs -f nginx

# Inspecter un conteneur
docker inspect mariadb
```

### Inspection des réseaux

```bash
# Lister les réseaux
docker network ls

# Inspecter le réseau inception
docker network inspect inception
```

### Inspection des volumes

```bash
# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data

# Vérifier les chemins des volumes
docker volume inspect inception_mariadb_data | grep Mountpoint
# Doit pointer vers /home/afodil-c/data/mariadb
```

### Accès aux conteneurs

```bash
# Ouvrir un shell dans un conteneur
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# Exécuter une commande spécifique
docker exec -it mariadb mysql -u root -p
docker exec -it wordpress wp --info --allow-root
```

### Tests MariaDB

```bash
# Se connecter à MariaDB (doit demander un mot de passe)
docker exec -it mariadb mysql -u root -p

# Une fois connecté :
SHOW DATABASES;
USE wordpress_db;  # Ou le nom de votre DB
SHOW TABLES;
SELECT * FROM wp_users;
EXIT;

# Tester avec l'utilisateur admin WordPress
docker exec -it mariadb mysql -u <DB_ADMIN_NAME> -p<DB_ADMIN_PWD>
SHOW DATABASES;
```

### Tests WordPress

```bash
# Vérifier que WP-CLI fonctionne
docker exec -it wordpress wp --info --allow-root

# Lister les utilisateurs WordPress
docker exec -it wordpress wp user list --allow-root

# Vérifier l'installation
docker exec -it wordpress wp core is-installed --allow-root && echo "Installed" || echo "Not installed"
```

### Tests Nginx

```bash
# Tester la configuration Nginx
docker exec -it nginx nginx -t

# Vérifier les certificats SSL
docker exec -it nginx ls -la /etc/ssl/certs/nginx-selfsigned.crt
docker exec -it nginx ls -la /etc/ssl/private/nginx-selfsigned.key

# Tester l'accès HTTP (doit échouer)
curl http://afodil-c.42.fr
# Ou
curl http://localhost:80

# Tester l'accès HTTPS (doit réussir)
curl -k https://afodil-c.42.fr
# -k ignore les erreurs de certificat auto-signé
```

### Arrêt et nettoyage

```bash
# Arrêter les conteneurs
make down
# Ou
docker-compose -f srcs/docker-compose.yml down

# Nettoyage complet
make fclean

# Rebuild complet
make re
```

### Test de persistance (redémarrage VM)

```bash
# 1. Faire des modifications sur WordPress (ajouter un post, un commentaire)
# 2. Redémarrer la VM
sudo reboot

# 3. Après redémarrage, relancer le projet
make

# 4. Vérifier que les modifications sont toujours là
# Ouvrir https://afodil-c.42.fr dans le navigateur
```

---

## Points de vérification de la scale

### Preliminaries ✅

- [x] Étudiant présent
- [x] Pas de triche
- [x] Fichiers corrects dans le repo Git
- [x] Repo cloné dans un dossier vide

### General Instructions ✅

- [x] Tous les fichiers dans `srcs/` à la racine
- [x] Makefile à la racine
- [x] Commande de nettoyage Docker exécutée
- [x] **PAS** de `network: host` dans docker-compose.yml
- [x] **PAS** de `links:` dans docker-compose.yml
- [x] Présence de `networks:` dans docker-compose.yml
- [x] **PAS** de `--link` dans les scripts Docker
- [x] **PAS** de `tail -f` dans les Dockerfiles ou entrypoints
- [x] **PAS** de `bash` ou `sh` en arrière-plan (sauf pour exécuter un script)
- [x] **PAS** de boucles infinies (`sleep infinity`, `while true`)
- [x] Makefile fonctionne correctement

### Project Overview ✅

**L'étudiant doit expliquer :**

1. **Comment Docker et docker-compose fonctionnent**
   - Docker : conteneurisation d'applications
   - docker-compose : orchestration de plusieurs conteneurs

2. **Différence entre image Docker avec/sans docker-compose**
   - Avec : gestion simplifiée, configuration centralisée
   - Sans : commandes manuelles, plus verbeux

3. **Avantages de Docker vs VM**
   - Légèreté, rapidité, portabilité
   - Partage du noyau vs émulation complète

4. **Structure des dossiers**
   - Organisation logique par service
   - Séparation des configurations

### Simple Setup ✅

- [x] Nginx accessible uniquement via port 443
- [x] Certificat SSL/TLS utilisé (accepter warning auto-signé)
- [x] WordPress installé et configuré (pas d'écran d'installation)
- [x] Accès via `https://afodil-c.42.fr`
- [x] **PAS** d'accès via `http://afodil-c.42.fr`

### Docker Basics ✅

- [x] Un Dockerfile par service (nginx, wordpress, mariadb)
- [x] Dockerfiles écrits à la main (pas de DockerHub)
- [x] Images basées sur Alpine ou Debian Buster
- [x] Noms des images = noms des services
- [x] Containers créés via docker-compose
- [x] Aucun crash

### Docker Network ✅

```bash
docker network ls  # Doit afficher 'inception'
```

- [x] Réseau visible avec `docker network ls`
- [x] L'étudiant peut expliquer docker-network

### NGINX with SSL/TLS ✅

- [x] Dockerfile présent
- [x] Container créé (`docker-compose ps`)
- [x] Port 80 inaccessible
- [x] `https://afodil-c.42.fr` affiche WordPress
- [x] TLSv1.2 ou TLSv1.3 utilisé (certificat auto-signé OK)

### WordPress with php-fpm ✅

- [x] Dockerfile présent
- [x] **PAS** de NGINX dans le Dockerfile
- [x] Container créé
- [x] Volume présent (`docker volume ls`)
- [x] Volume pointe vers `/home/afodil-c/data/wordpress`
- [x] Possibilité d'ajouter un commentaire
- [x] Connexion admin fonctionne
- [x] Username admin ne contient **PAS** 'admin' ou 'Admin'
- [x] Édition de page fonctionne

### MariaDB ✅

- [x] Dockerfile présent
- [x] **PAS** de NGINX dans le Dockerfile
- [x] Container créé
- [x] Volume présent
- [x] Volume pointe vers `/home/afodil-c/data/mariadb`
- [x] **IMPOSSIBLE** de se connecter en root sans mot de passe
- [x] Connexion avec utilisateur fonctionne
- [x] Base de données non vide

### Persistence ✅

- [x] Redémarrage de la VM
- [x] Relancement de docker-compose
- [x] WordPress et MariaDB toujours configurés
- [x] Modifications précédentes toujours présentes

---

## Checklist de défense

### Avant la correction

- [ ] Nettoyer complètement Docker
- [ ] Vérifier `/etc/hosts`
- [ ] Créer les dossiers de données
- [ ] Tester `make` depuis zéro
- [ ] Vérifier que le site s'affiche
- [ ] Préparer les explications théoriques

### Pendant la correction

**Phase 1 : Vérifications initiales**
- [ ] Montrer la structure du projet
- [ ] Expliquer docker-compose.yml
- [ ] Lancer `make`

**Phase 2 : Démonstrations**
- [ ] Ouvrir `https://afodil-c.42.fr`
- [ ] Se connecter à WordPress (admin)
- [ ] Ajouter un commentaire
- [ ] Éditer une page
- [ ] Montrer `docker ps`
- [ ] Montrer `docker network ls`
- [ ] Montrer `docker volume ls` et `inspect`

**Phase 3 : Tests techniques**
- [ ] Tester connexion MariaDB
- [ ] Montrer les Dockerfiles
- [ ] Expliquer les entrypoints
- [ ] Montrer le fichier .env

**Phase 4 : Persistance**
- [ ] Faire une modification sur WordPress
- [ ] Redémarrer (`sudo reboot`)
- [ ] Relancer `make`
- [ ] Vérifier que la modification est toujours là

---

## Questions fréquentes

### 1. Qu'est-ce qu'un conteneur Docker ?

Un conteneur est une instance isolée d'une application qui partage le noyau du système hôte mais possède son propre système de fichiers, réseau et processus.

### 2. Quelle est la différence entre une image et un conteneur ?

- **Image** : template en lecture seule (blueprint)
- **Conteneur** : instance en cours d'exécution d'une image

### 3. Pourquoi ne pas utiliser `tail -f` ?

Parce que ce n'est pas le processus principal du service. Le conteneur doit exécuter le daemon du service (nginx, php-fpm, mysqld) en foreground comme PID 1.

### 4. Qu'est-ce que PID 1 ?

Le premier processus dans un conteneur. Il doit :
- Rester actif pour que le conteneur tourne
- Gérer proprement les signaux système
- Être le service principal (pas un shell ou tail)

### 5. Pourquoi Alpine ou Debian ?

Ce sont des distributions légères optimisées pour les conteneurs. Alpine est la plus petite (~5 Mo), Debian Buster est plus complète.

### 6. Que fait `restart: always` ?

Redémarre automatiquement le conteneur en cas de crash ou après un reboot du système.

### 7. Pourquoi séparer Nginx et WordPress ?

- **Principe de responsabilité unique** : chaque conteneur fait une seule chose
- **Nginx** : reverse proxy SSL + serveur web
- **WordPress** : PHP-FPM (traitement PHP uniquement)

### 8. Comment les conteneurs communiquent ?

Via le réseau Docker bridge :
- Résolution DNS automatique par nom de service
- Exemple : `wordpress` peut contacter `mariadb:3306`
- Isolation du réseau hôte

### 9. Pourquoi utiliser des volumes ?

Pour **persister les données** :
- Sans volume : données perdues si conteneur supprimé
- Avec volume : données conservées sur l'hôte

### 10. Qu'est-ce qu'une variable d'environnement ?

Une variable accessible dans le conteneur, définie dans `.env` et injectée via `env_file` dans docker-compose.yml. Permet de séparer la configuration du code.

---

## Commandes de debug rapide

### Le site ne s'affiche pas

```bash
# Vérifier que les conteneurs tournent
docker ps

# Vérifier les logs
docker logs nginx
docker logs wordpress
docker logs mariadb

# Vérifier le réseau
docker network inspect inception

# Tester la connexion
curl -k https://localhost:443
```

### Problème de volume

```bash
# Vérifier les permissions
ls -la /home/afodil-c/data/

# Vérifier les volumes Docker
docker volume ls
docker volume inspect inception_mariadb_data
docker volume inspect inception_wordpress_data
```

### WordPress ne se connecte pas à MariaDB

```bash
# Tester la connexion depuis le conteneur WordPress
docker exec -it wordpress ping mariadb

# Vérifier que MariaDB écoute sur 0.0.0.0:3306
docker exec -it mariadb netstat -tuln | grep 3306

# Tester la connexion SQL depuis WordPress
docker exec -it wordpress mysql -hmariadb -u<USER> -p<PWD>
```

---

## Points critiques qui invalident le projet

### ❌ Échecs automatiques (évaluation arrêtée)

1. **`network: host`** dans docker-compose.yml
2. **`links:`** dans docker-compose.yml
3. **`--link`** dans les scripts Docker
4. **`tail -f`** dans ENTRYPOINT
5. **Boucles infinies** (`sleep infinity`, `while true`)
6. **Pas de réseau** dans docker-compose.yml
7. **Images non basées** sur Alpine/Debian Buster
8. **Images DockerHub** (sauf Alpine/Debian)
9. **Admin username** contient 'admin' ou 'Admin'
10. **Connexion root** à MariaDB sans mot de passe
11. **Port 80 accessible** (HTTP)
12. **Pas de TLS** v1.2 ou v1.3
13. **Mot de passe** en clair dans Dockerfile

---

## Résumé : Ce que je dois savoir expliquer

1. ✅ Docker vs VM
2. ✅ Docker vs Docker Compose
3. ✅ Comment fonctionne un réseau Docker
4. ✅ Pourquoi TLS/SSL et port 443
5. ✅ PID 1 et entrypoints
6. ✅ Pourquoi pas de `tail -f`
7. ✅ Comment communiquent les conteneurs
8. ✅ Pourquoi les volumes
9. ✅ Architecture du projet (nginx → wordpress → mariadb)
10. ✅ Sécurité : pas de mots de passe en clair, variables d'environnement

---

## Bon courage pour ta défense ! 🚀
