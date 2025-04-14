Ce script Bash permet de chiffrer des volumes de stockage à l'aide de LUKS (Linux Unified Key Setup) et de les monter automatiquement après chiffrement. Il offre une interface simple avec des options configurables pour le type de chiffrement, le système de fichiers, le nom du volume, et le point de montage.

Prérequis . Ce script doit être exécuté avec les privilèges root. . Vous devez avoir les outils suivants installés sur votre système : - cryptsetup (pour gérer les volumes chiffrés avec LUKS) - mkfs.ext4 (ou un autre utilitaire pour formater le volume)

Exemple d'utilisation

" sudo ./script.sh -t aes-xts-plain64 -f ext4 -n mon_volume -m /mnt/chiffre "

Dans cet exemple, le script : . Utilise le chiffrement aes-xts-plain64. . Formate le volume chiffré en système de fichiers ext4. . Nomme le volume chiffré mon_volume. . Monte le volume sur /mnt/chiffre.

Pour affichier l'aide et la liste des otpions diponibles exécutez : " ./script.sh -h "

Remarques

. Si un volume est déjà monté, le script vous en avertira et vous demandera de le démonter avant de procéder. . Ce script ne chiffre que les volumes spécifiés. Il ne peut pas chiffrer des partitions système actives (comme /). . La valeur par défaut du type de chiffrement est aes-xts-plain64 et celle du système de fichiers est ext4. Vous pouvez personnaliser ces paramètres via les options.
