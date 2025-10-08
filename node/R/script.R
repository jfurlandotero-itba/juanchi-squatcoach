# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada <- fromJSON(file("stdin"))

# Definir función
func <- function(data) {
  row_sums <- sapply(data, sum)
  names(row_sums) <- seq_along(row_sums)
  return(as.list(row_sums))
}

# Ejecutar función
resultado <- func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado = resultado)), "\n")
flush.console()
