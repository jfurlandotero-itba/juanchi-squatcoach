# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada  <-  fromJSON(file("stdin"))

# Definir función
func  <-  function(dataframe) {

#Cada  vec tiene n filas, donde n es la cantidad de frames en el dataframe
vec_timestamps  <-  numeric(nrow(dataframe))
vec_espalda_cuello  <-  numeric(nrow(dataframe))
vec_mirada  <-  numeric(nrow(dataframe))
vec_profunda  <-  numeric(nrow(dataframe))
vec_inclinacion  <-  numeric(nrow(dataframe))
vec_manos_hombros  <-  numeric(nrow(dataframe))
vec_manos_codos  <-  numeric(nrow(dataframe))
vec_manos_pendiente  <-  numeric(nrow(dataframe))
vec_pies  <-  numeric(nrow(dataframe))
vec_errores <- numeric(8)
vec_debug <- numeric(nrow(dataframe))

#Sumas de cantidad de errores
sum_espalda_cuello <- 0
sum_mirada <- 0
sum_profunda <- 0
sum_inclinacion <- 0
sum_manos_hombros <- 0
sum_manos_codos <- 0
sum_manos_pendiente <- 0
sum_pies <- 0


# Traduccion index vec errores
index_mirada <- 1
index_espalda_cuello <- 2
index_profunda <- 3
index_inclinacion <- 4
index_manos_hombros <- 5
index_manos_codos <- 6
index_manos_pendiente <- 7
index_pies <- 8

# Traduccion de coordenadas de los nodos
x2  <-  11
y2  <-  12
z2  <-  13
x7  <-  31
y7  <-  32
z7  <-  33
x11  <-  47
y11  <-  48
z11  <-  49
x13  <-  55
y13  <-  56
z13  <-  57
x15  <-  63
y15  <-  64
z15  <-  65
x23  <-  95
y23  <-  96
z23  <-  97
x25  <-  103
y25  <-  104
z25  <-  105
x29  <-  119
y29  <-  120
z29  <-  121
x31  <-  127
y31  <-  128
z31  <-  129

#Funcion compracion tolerancia
comparar <- function(relacion, tolerancia, frame_num, vec, suma) {
  if (relacion > tolerancia) {
    vec[frame_num]  <-  1
    suma <- suma + 1
  } else {
    vec[frame_num]  <-  0
  }
  return(list(vec = vec, suma = suma))
}

#Matriz de Numericos
numeric_vec <- numeric(nrow(dataframe) * ncol(dataframe))  # tamaño total
index <- 1

# Ejecucion de las reglas por frame
for (fila in 1:nrow(dataframe)) {

  for (col in 1:ncol(dataframe)) {
    # Convertir cada valor a numeric y guardarlo en numeric_vec
    numeric_vec[index] <- as.numeric(dataframe[fila, col])
    index <- index + 1
  }

  pos <- function(coord){
    return(numeric_vec[coord])
  }
  vec_timestamps[fila]  <-  numeric_vec[1]

  m_espalda <- (pos(y23) - pos(y11)) / (pos(x23) - pos(x11))
  m_cuello <- (pos(y11) - pos(y7)) / (pos(x11) - pos(x7))
  res <- comparar(abs(m_espalda - m_cuello), 0, fila, vec_espalda_cuello,  sum_espalda_cuello)
  vec_espalda_cuello <- res$vec
  sum_espalda_cuello <- res$suma

  res <- comparar(abs(pos(y2) - pos(y7)),    0, fila, vec_mirada,          sum_mirada)
  vec_mirada <- res$vec
  sum_mirada <- res$suma

  res <- comparar(pos(y25) - pos(y23),       0, fila, vec_profunda,        sum_profunda)
  vec_profunda <- res$vec
  sum_profunda <- res$suma

  res <- comparar(pos(x11) - pos(x25),       0, fila, vec_inclinacion,     sum_inclinacion)
  vec_inclinacion <- res$vec
  sum_inclinacion <- res$suma

  res <- comparar(pos(x15) - pos(x11),       0, fila, vec_manos_hombros,   sum_manos_hombros)
  vec_manos_hombros <- res$vec
  sum_manos_hombros <- res$suma

  res <- comparar(pos(x13) - pos(x15),       0, fila, vec_manos_codos,     sum_manos_codos)
  vec_manos_codos <- res$vec
  sum_manos_codos <- res$suma

  res <- comparar(pos(y11) - pos(y13),       0, fila, vec_manos_pendiente, sum_manos_pendiente)
  vec_manos_pendiente <- res$vec
  sum_manos_pendiente <- res$suma

  res <- comparar(abs(pos(y31) - pos(y29)),  0, fila, vec_pies, sum_pies)
  vec_pies <- res$vec
  sum_pies <- res$suma
}

#Determinaciones

determinar <- function(index, suma, tolerancia) {
  if(suma > tolerancia) {
    vec_errores[index] <<- 1
  }
}

#Mensajes de salida de problemas
determinar(index_espalda_cuello, sum_espalda_cuello, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: No encorves el cuello, alinea tu cuello y tu columna.”)

determinar(index_mirada, sum_mirada, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén la cabeza y la mirada rectas, paralelas al suelo.”)

determinar(index_profunda, sum_profunda, 0)
#cat(“Se detectó un problema durante el ejercicio: La sentadilla no es profunda. Para hacer una sentadilla profunda debes bajar la cadera por debajo de la altura de las rodillas.”)

determinar(index_inclinacion, sum_inclinacion, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: No inclines el tronco por delante de las rodillas.”)

determinar(index_manos_hombros, sum_manos_hombros, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)

determinar(index_manos_codos, sum_manos_codos, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)

determinar(index_manos_pendiente, sum_manos_pendiente, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)

determinar(index_pies, sum_pies, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén los pies planos y bien apoyados en el suelo.”)

library(jsonlite)
return(toJSON(vec_errores))
}

# Ejecutar función
resultado  <-  func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado  <-  resultado)), "\n")
flush.console()
