#!/bin/bash

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo 'Chiffrement de volumes avec LUKS'
    echo ''
    echo 'Options disponibles :'
    echo '  -t, --type TYPE           Spécifier le type de chiffrement (par défaut : aes-xts-plain64)'
    echo '  -f, --filesystem TYPE     Spécifier le système de fichiers à utiliser (par défaut : ext4)'
    echo '  -n, --name NAME           Spécifier le nom du volume chiffré (par défaut : nom du fichier sans extension)'
    echo '  -m, --mount POINT         Spécifier le point de montage (par défaut : /mnt/nom_du_volume_luks)'
    echo '  -h, --help                Afficher cette aide'
    echo ''
    exit 0
}

if [ $(id -u) -ne 0 ]; then
    echo 'Ce script doit être exécuté en tant que root.'
    exit 1
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--type)
            encryption_type="$2"
	    # Je décale les paramètres de 2 champs pour prendre en compte l'option et l'argument
            shift 2
            ;;
        -f|--filesystem)
            filesystem="$2"
            shift 2
            ;;
        -n|--name)
            luks_name="$2"
            shift 2
            ;;
        -m|--mount)
            mount_point="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Option invalide: $1"
            exit 1
            ;;
    esac
done

volumes=()
while true; do
    read -p 'Entrez le chemin du volume à chiffrer (laissez vide pour terminer) : ' volume
    if [[ -z "$volume" ]]; then
        break
    elif [[ ! -e "$volume" ]]; then
        echo "Le chemin $volume n'existe pas. Veuillez entrer un chemin valide."
    else
        volumes+=("$volume")
    fi
done

for volume in "${volumes[@]}"; do
    luks_name="${volume##*/}_luks"
    mount_point="/mnt/${luks_name}"

    if grep -qs "$volume" /proc/mounts; then
        echo "Le volume $volume est déjà monté. Veuillez le démonter avant de continuer."
    fi

    read -p "Êtes-vous sûr de vouloir chiffrer $volume ? (oui/non) : " choice
    if [[ "$choice" != "oui" ]]; then
        echo "Opération annulée."
    fi

    # Chiffrement du volume avec LUKS
    echo "Chiffrement du volume $volume avec LUKS..."
    cryptsetup luksFormat --type "$encryption_type" "$volume"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de chiffrer le volume $volume avec LUKS."
    fi

    echo "Ouverture du volume chiffré..."
    cryptsetup open "$volume" "$luks_name"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible d'ouvrir le volume chiffré $volume."
    fi

    echo "Création d'un système de fichiers sur le volume chiffré..."
    mkfs.ext4 "/dev/mapper/$luks_name"
    if [ $? -ne 0 ]; then
        echo 'Erreur : Impossible de créer un système de fichiers sur le volume chiffré.'
    fi

    echo "Montage du volume chiffré sur $mount_point..."
    mkdir -p "$mount_point"
    mount "/dev/mapper/$luks_name" "$mount_point"
    if [ $? -ne 0 ]; then
        echo "Erreur : Impossible de monter le volume chiffré sur $mount_point."
    fi

    echo "Le volume $volume a été chiffré avec succès et monté sur $mount_point."
done
