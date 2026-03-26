#!/bin/bash

echo "====================================="
echo "🌿 Cambio de rama"
echo "====================================="

# Listar ramas locales disponibles
echo "Ramas disponibles:"
git branch --list --format="  %(refname:short)" | grep -v '^\s*$'

echo ""
read -p "Introduce el nombre de la rama a la que te quieres cambiar: " target_branch

if [ -z "$target_branch" ]; then
    echo "❌ No se ha introducido ninguna rama. Saliendo..."
    exit 1
fi

# Verificar si la rama actual es la misma
current_branch=$(git branch --show-current)
if [ "$target_branch" == "$current_branch" ]; then
    echo "⚠️  Ya estás en la rama '$target_branch'."
    exit 0
fi

# Verificar si la rama existe localmente
if ! git show-ref --verify --quiet refs/heads/"$target_branch"; then
    read -p "⚠️  La rama '$target_branch' no existe localmente. ¿Quieres crearla? (s/n): " crear_rama
    if [[ "$crear_rama" =~ ^[sS]$ ]]; then
        git branch "$target_branch"
    else
        echo "❌ Operación cancelada."
        exit 1
    fi
fi

# Comprobar si hay cambios sin guardar
CHANGES=$(git status --porcelain)

if [ -n "$CHANGES" ]; then
    echo ""
    echo "⚠️  Tienes cambios sin confirmar (o archivos sin seguimiento) en tu espacio de trabajo."
    read -p "¿Quieres llevarte estos cambios a la rama '$target_branch'? (s/n/c para cancelar): " llevar_cambios
    
    case "$llevar_cambios" in
        [sS])
            echo "📦 Guardando cambios temporalmente y cambiando de rama..."
            # Guardamos los cambios incluyendo archivos untracked
            git stash push --include-untracked -q -m "Migración temporal a $target_branch"
            
            git checkout "$target_branch"
            
            echo "📥 Aplicando los cambios en la nueva rama..."
            git stash pop -q
            echo "✅ Cambiado a la rama '$target_branch' con tus cambios aplicados."
            ;;
        [nN])
            echo "📦 Guardando tus cambios de forma segura en el stash..."
            git stash push --include-untracked -q -m "Cambios pausados en $current_branch antes de ir a $target_branch"
            
            git checkout "$target_branch"
            echo "✅ Cambiado a la rama '$target_branch'. Tus cambios anteriores están a salvo en el stash (usa 'git stash list' para verlos)."
            ;;
        *)
            echo "❌ Operación cancelada."
            exit 1
            ;;
    esac
else
    # No hay cambios
    git checkout "$target_branch"
    echo "✅ Cambiado a la rama '$target_branch'."
fi
