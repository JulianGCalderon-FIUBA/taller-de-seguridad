# Taller de Seguridad

Scripts para levantar las maquinas virtuales de taller de seguridad, en macOS

## Requerimientos

- [socat](https://formulae.brew.sh/formula/socat)

Para funcionar, requiere una carpeta `data` con los siguientes archivos:

- `data/edk2-aarch64-code.fd`: UEFI Firmware para aarch64. Está incluido en la instalación de QEMU de Macos.
- `data/kali-arm64.iso`: Disco de instalación de Kali para arm64.
- `data/kali-x86.ova`: Provisto por la catedra.
- `data/owned.zip`: Provisto por la catedra.

## Uso

El repositorio incluye scripts no muy bién documentados.

```bash
make usage
```

### Levantar Owned

Para levantar `owned`:

```bash
make run-owned
```

Y en otra terminal:

```bash
./ssh.sh owned
```

### Instalar Kali

Para levantar `kali` nativo, primero hay que instalarlo.

```bash
make generate-kali
```

Y en otra terminal:

```bash
make serial
```

Asegurarse de editar el archivo `.env` para que tenga el username de Kali correcto.

### Levantar Kali

Una vez finalizada la instalación, la imagen se puede correr con:

```bash
make run-kali
```

Y en otra terminal:

```bash
./ssh.sh kali
```

## Uso Avanzado

Para mas control, se puede llamar a `qemu.sh` y `ssh.sh`, o invocar QEMU directamente.
