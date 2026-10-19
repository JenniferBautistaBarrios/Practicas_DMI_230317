# Documentacion de arquitectura - KittyTokTik / Practica 04

Esta carpeta reune los diagramas de arquitectura de KittyTokTik y la documentacion para consultarlos.

## Diagramas

- [Diagramas Mermaid de la Practica 04](practica04_diagramas.md): contiene dos diagramas editables. El primero describe el Provider local, los videos, los Me gusta, las preferencias y las temporadas. El segundo documenta la estructura disponible de Clean Architecture, sus fuentes y los componentes solicitados que todavia faltan.
- [Diagrama interactivo de la seccion 8](seccion_8_toktik_arquitectura_interna.html): vista HTML con navegacion, busqueda y estilos visuales seleccionables. Abre el archivo en un navegador.

## Alcance reflejado

Los diagramas Mermaid describen el cableado encontrado en el codigo del proyecto: Provider, feeds locales, persistencia de preferencias, reproduccion de videos y datasources de PeerTube, Internet Archive y Wikimedia Commons. Tambien distinguen las fuentes que no estan conectadas al arranque de la aplicacion y los componentes no implementados, como los casos de uso, el mapper remoto separado y los datasources de YouTube, Vimeo y Dailymotion.

La insignia "8 videos" del encabezado HTML es un rotulo de presentacion solicitado; no modifica el catalogo ni la reproduccion. Los videos disponibles siguen determinados por los assets y el codigo del proyecto.

## Matricula

Jennifer Bautista Barrios - 230317.
