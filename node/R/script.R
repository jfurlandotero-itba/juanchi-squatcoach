# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada <- fromJSON(file("stdin"))

# Definir función
func <- function(data) {
  result <- numeric(nrow(data))
  for (fila in 1:nrow(data)) {
    result[fila] <- data[fila,1]
  }
  return(result)
  }

# Ejecutar función
resultado <- func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado = resultado)), "\n")
flush.console()
