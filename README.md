# Azure deployment using modules Terraform

Déploiement automatisé d’une mini infra cloud sécurisée sur Microsoft Azure avec un module Terraform developpé. Architecture réseau segmentée (public / privé), machines virtuelles et contrôle d’accès SSH via Network Security Groups.

## Description de l’architecture déployée

1️⃣ Création d’un groupe de ressources.

2️⃣ Mise en place du réseau virtuel.

3️⃣ Sous-réseau public.

Le sous-réseau public héberge une machine virtuelle avec une adresse IP publique permettant l’accès depuis l’extérieur.
Ce sous-réseau est destiné aux ressources devant être accessibles depuis Internet, notamment pour l’administration à distance.

4️⃣ Sous-réseau privé

Le sous-réseau privé héberge une machine virtuelle non exposée directement à Internet.
Ce sous-réseau est isolé et conçu pour héberger des ressources internes nécessitant un niveau de sécurité renforcé.

5️⃣ Sécurisation par groupes de sécurité réseau (NSG)

Deux Network Security Groups (NSG) sont définis afin de contrôler les flux réseau :

- NSG du sous-réseau public.  
  - Autorise les connexions SSH (port 22) depuis l’extérieur.  
  - Permet l’administration de la machine virtuelle publique.
    
- NSG du sous-réseau privé.  
  - Autorise les connexions SSH uniquement depuis les machines situées dans le sous-réseau public.  
  - Bloque tout accès direct depuis Internet.  

 ### Schéma de l’architecture ###

![Schéma de l'architecture](images.png)
