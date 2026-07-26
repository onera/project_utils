# - Find AMG library
# This module defines:
#  AMG_FOUND - True if AMG was found
#  Target 'amg' - Imported target for linking

include(FindPackageHandleStandardArgs)

# 1. Chercher le header
find_path(AMG_INCLUDE_DIR
    NAMES amgi_api.h
    HINTS ENV AMG_ROOT
    PATH_SUFFIXES include
)

# 2. Chercher la bibliothèque partagée
find_library(AMG_LIBRARY
    NAMES amg
    HINTS ENV AMG_ROOT
    PATH_SUFFIXES lib
)

# 3. Valider les trouvailles (gère automatiquement les messages standard)
find_package_handle_standard_args(AMG
    FOUND_VAR AMG_FOUND
    REQUIRED_VARS AMG_LIBRARY AMG_INCLUDE_DIR
)

# 4. Créer la cible IMPORTED si tout est OK et qu'elle n'existe pas déjà
if(AMG_FOUND AND NOT TARGET amg)
    add_library(amg SHARED IMPORTED)
    set_target_properties(amg PROPERTIES
        IMPORTED_LOCATION "${AMG_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${AMG_INCLUDE_DIR}"
    )
endif()

# Nettoyer le cache CMake pour les variables internes
mark_as_advanced(AMG_INCLUDE_DIR AMG_LIBRARY)
