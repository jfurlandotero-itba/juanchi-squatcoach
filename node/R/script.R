# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada <- fromJSON(file("stdin"))

# Definir función
func <- function(data) {
  return(return(data[1]))
}

# Ejecutar función
resultado <- func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado = resultado)), "\n")
flush.console()
