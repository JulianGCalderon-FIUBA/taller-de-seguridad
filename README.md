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
make ssh-owned
```

### Instalar Kali

Para levantar `kali` nativo, primero hay que instalarlo.

```bash
make kali.qcow2
```

Y en otra terminal:

```bash
make serial
```

### Levantar Kali

Una vez finalizada la instalación, la imagen se puede correr con:

```bash
make run-kali
```

Y en otra terminal:

```bash
make ssh-kali
```

## Uso Avanzado

Para mas control, se puede llamar a `qemu.sh` y `ssh.sh`, o invocar QEMU directamente.
