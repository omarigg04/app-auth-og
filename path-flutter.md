# Solución Permanente para Flutter PATH en WSL

## El Problema

Tu Flutter funciona perfectamente después de la instalación, pero al abrir una nueva terminal o al día siguiente, WSL no reconoce el comando `flutter`. Esto indica que el PATH no se está guardando permanentemente.

## Diagnóstico Rápido

Primero, verifica qué está pasando:

```bash
# Verificar si Flutter sigue instalado
ls -la /snap/bin/flutter

# Verificar el PATH actual
echo $PATH | grep snap

# Verificar si snap está en el PATH
which flutter
```

## Solución Paso a Paso

### Paso 1: LIMPIAR la ruta de Flutter de Windows

**¡IMPORTANTE!** Primero debes eliminar la referencia a Flutter de Windows:

```bash
# Abrir .bashrc para limpiar referencias de Windows
nano ~/.bashrc

# Buscar y ELIMINAR líneas como estas:
# export PATH="$PATH:/mnt/c/Users/omari/Desktop/code/TestingNestJS/flutter/bin"
# O cualquier línea que contenga "/mnt/c/" y "flutter"

# Guardar y salir (Ctrl+X, Y, Enter)
```

### Paso 2: Verificar que Flutter está instalado via Snap

```bash
# Confirmar que Flutter está instalado via Snap
snap list | grep flutter

# Si no aparece, reinstalar:
sudo snap install flutter --classic
```

### Paso 2: Configurar el PATH Permanentemente

**Opción A: Modificar ~/.bashrc (Recomendado)**

```bash
# Abrir el archivo de configuración
nano ~/.bashrc

# Agregar al FINAL del archivo estas líneas:
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/snap/bin/flutter"

# Guardar y salir (Ctrl+X, luego Y, luego Enter)
```

**Opción B: Usar ~/.profile (Alternativa)**

```bash
# Si .bashrc no funciona, usar .profile
nano ~/.profile

# Agregar las mismas líneas:
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/snap/bin/flutter"
```

### Paso 3: Crear un Enlace Simbólico (Método Alternativo)

Si el PATH sigue sin funcionar:

```bash
# Crear enlace simbólico en /usr/local/bin
sudo ln -s /snap/bin/flutter /usr/local/bin/flutter

# Verificar que se creó correctamente
ls -la /usr/local/bin/flutter
```

### Paso 4: Aplicar los Cambios

```bash
# Recargar la configuración
source ~/.bashrc

# O reiniciar la terminal completamente
# Cerrar y abrir nueva terminal WSL
```

### Paso 5: Verificación Final

```bash
# Cerrar completamente WSL y volver a abrir
# Luego ejecutar:

which flutter
# Debería mostrar: /snap/bin/flutter o /usr/local/bin/flutter

flutter --version
# Debería funcionar sin problemas

# Verificar que persiste después de reiniciar
echo $PATH | grep snap
```

## Soluciones Adicionales

### Si WSL no Carga .bashrc Automáticamente

```bash
# Agregar al archivo ~/.bash_profile
nano ~/.bash_profile

# Contenido:
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
```

### Configuración Global del Sistema

```bash
# Agregar Flutter al PATH del sistema (requiere sudo)
echo 'export PATH="$PATH:/snap/bin"' | sudo tee -a /etc/profile

# Reiniciar WSL después de esto
```

### Script de Inicialización Personalizado

```bash
# Crear script que se ejecute al iniciar
nano ~/flutter-init.sh

# Contenido del script:
#!/bin/bash
export PATH="$PATH:/snap/bin"
export PATH="$PATH:/snap/bin/flutter"
alias flutter='/snap/bin/flutter'

# Hacer ejecutable
chmod +x ~/flutter-init.sh

# Agregar al .bashrc para que se ejecute automáticamente
echo 'source ~/flutter-init.sh' >> ~/.bashrc
```

## Verificación de Persistencia

Para asegurarte de que la solución es permanente:

```bash
# 1. Cerrar completamente WSL
# 2. Abrir nueva terminal WSL
# 3. Ejecutar sin source:

flutter --version

# Si funciona, ¡problema resuelto!
```

## Causas Comunes del Problema

1. **WSL no carga .bashrc**: Algunas configuraciones de WSL no cargan automáticamente .bashrc
2. **PATH se resetea**: El PATH se reinicia en cada sesión
3. **Snap no está en PATH**: El directorio /snap/bin no está incluido por defecto
4. **Permisos**: Problemas con permisos de los archivos de configuración

## Comando de Emergencia

Si nada funciona, usa este comando que siempre debería funcionar:

```bash
# Crear alias permanente
echo 'alias flutter="/snap/bin/flutter"' >> ~/.bashrc
source ~/.bashrc

# Ahora 'flutter' debería funcionar siempre
```

## Verificación de Archivos de Configuración

```bash
# Verificar que los archivos existen y tienen el contenido correcto
cat ~/.bashrc | grep -E "(snap|flutter)"
cat ~/.profile | grep -E "(snap|flutter)"

# Verificar permisos
ls -la ~/.bashrc ~/.profile
```

## Troubleshooting Avanzado

### Si el problema persiste:

```bash
# 1. Verificar qué shell estás usando
echo $SHELL

# 2. Si usas zsh en lugar de bash:
nano ~/.zshrc
# Agregar las mismas líneas de export PATH

# 3. Verificar orden de carga de archivos
echo "Loading .bashrc" >> ~/.bashrc
echo "Loading .profile" >> ~/.profile
```

### Solución Nuclear (Last Resort)

```bash
# Reinstalar Flutter y configurar desde cero
sudo snap remove flutter
sudo snap install flutter --classic

# Agregar al PATH con comando directo
echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
echo 'export PATH="$PATH:/snap/bin/flutter"' >> ~/.bashrc
source ~/.bashrc

# Crear enlace simbólico como respaldo
sudo ln -sf /snap/bin/flutter /usr/local/bin/flutter
```

## Recomendación Final

La solución más confiable es usar **ambos métodos**:

1. **PATH en .bashrc** (para uso normal)
2. **Enlace simbólico** (como respaldo)

```bash
# Método combinado
echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
sudo ln -s /snap/bin/flutter /usr/local/bin/flutter
source ~/.bashrc
```

Esto garantiza que Flutter funcione permanentemente, independientemente de cómo se comporte WSL con la carga de archivos de configuración.