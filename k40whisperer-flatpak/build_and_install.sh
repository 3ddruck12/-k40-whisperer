#!/bin/bash

# Variablen
MANIFEST="com.k40whisperer.json"
REPO_DIR="./my-local-repo"
BUILD_DIR="./build-dir"
APP_ID="org.skorch.k40whisperer"
UDEV_RULES="97-ctc-lasercutter.rules"

# Prüfen, ob Flatpak installiert ist
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak ist nicht installiert. Bitte installiere Flatpak und versuche es erneut."
    exit 1
fi

# Schritt 1: Verzeichnis bereinigen
echo "Bereinige vorherige Build-Verzeichnisse..."
rm -rf "$BUILD_DIR" "$REPO_DIR"

# Schritt 2: Build starten
echo "Baue die Flatpak-Anwendung..."
flatpak-builder --force-clean "$BUILD_DIR" "$MANIFEST"
if [ $? -ne 0 ]; then
    echo "Fehler beim Build der Anwendung!"
    exit 1
fi

# Schritt 3: Repository erstellen
echo "Erstelle lokales Flatpak-Repository..."
flatpak-builder --repo="$REPO_DIR" "$BUILD_DIR" "$MANIFEST"
if [ $? -ne 0 ]; then
    echo "Fehler beim Erstellen des Repositories!"
    exit 1
fi

# Schritt 4: Repository hinzufügen
echo "Füge das Repository hinzu..."
flatpak --user remote-add --no-gpg-verify my-local-repo "$REPO_DIR"
if [ $? -ne 0 ]; then
    echo "Fehler beim Hinzufügen des Repositories!"
    exit 1
fi

# Schritt 5: Anwendung installieren
echo "Installiere die Anwendung..."
flatpak --user install my-local-repo "$APP_ID" -y
if [ $? -ne 0 ]; then
    echo "Fehler bei der Installation der Anwendung!"
    exit 1
fi

# Schritt 6: udev-Regeln kopieren
if [ -f "$UDEV_RULES" ]; then
    echo "Installiere udev-Regeln..."
    sudo cp "$UDEV_RULES" /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "udev-Regeln erfolgreich installiert."
else
    echo "udev-Regeln ($UDEV_RULES) nicht gefunden. Überspringe diesen Schritt."
fi

echo "Flatpak-Anwendung erfolgreich gebaut und installiert!"
exit 0

