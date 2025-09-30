# # Necesario para comunicar con Node
library(jsonlite)

# Tomo argumentos de Node (los pasa r-script como lista)
entrada <- fromJSON(file("stdin"))

# # Defino la funcion
func <- function(data) {
    # data is expected to be a list of numeric vectors (each row is an array)
    # Calculate the sum for each row and index them
    row_sums <- sapply(data, sum)
    names(row_sums) <- seq_along(row_sums)
    return(as.list(row_sums))
}

# Uso la función con los datos recibidos
resultado <- func(entrada$valor)

# Devuelvo el resultado a Node en formato JSON
cat(toJSON(list(resultado = resultado)), "\n")
flush.console()