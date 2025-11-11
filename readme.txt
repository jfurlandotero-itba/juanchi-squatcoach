Para ejecutar el servidor de node:
    - Descargar Node, NPM y R
    - En la terminal (./juanchi-squatcoach/node/): 
        npm i (instala los paquetes y librerias)
        npm run run (ejecutar el codigo. Se hostea en el puerto 3002)
    - Crear variable de entorno Rscript
        Al descargar e instalar R se creara un archivo Rscript.exe en una direccion como 
        "C:\Program Files\R\R-4.5.1\bin\". Se debe crear una variable de entorno llamada
        RSCRIPT_PATH con el path de Rscript.exe
Para hostear la página web:
    - Está preparado para hostear con Netlify, ver url del api host en ./juanchi-squatcoach/netlify/functions/proxy.js
    - Si se desea hostear localmente, revisar función fetchCSVData de ./juanchi-squatcoach/index.html y reroutear a localhost
