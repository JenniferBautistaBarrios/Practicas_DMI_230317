# Iconos por temporada

Los maestros proporcionados están en esta carpeta: `normal.png`, `halloween.png`, `navidad.png` y `san-valentin.png` (1024 × 1024). Flutter usa directamente estos archivos para el selector, el splash y el favicon según la temporada.

Para regenerar recursos de launcher de Android, iOS, macOS y web desde estos maestros, ejecutar desde la raíz del proyecto:

```powershell
powershell -ExecutionPolicy Bypass -File tool/install_season_icons.ps1
```
