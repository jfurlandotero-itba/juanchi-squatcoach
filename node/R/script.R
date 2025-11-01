# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada  <-  fromJSON(file("stdin"))

# Definir función
func  <-  function(dataframe) {

#Cada  vec tiene n filas, donde n es la cantidad de frames en el dataframe
vec_timestamps  <-  numeric(nrow(dataframe))
vec_mirada  <-  numeric(nrow(dataframe))
vec_profunda  <-  numeric(nrow(dataframe))
vec_inclinacion  <-  numeric(nrow(dataframe))
vec_manos_codos  <-  numeric(nrow(dataframe))
vec_manos_pendiente  <-  numeric(nrow(dataframe))
vec_pies  <-  numeric(nrow(dataframe))
vec_postura  <-  numeric(nrow(dataframe))
vec_errores <- numeric(7)
vec_debug <- numeric(nrow(dataframe))

#Sumas de cantidad de errores
sum_mirada <- 0
sum_profunda <- 0
sum_inclinacion <- 0
sum_manos_codos <- 0
sum_manos_pendiente <- 0
sum_pies <- 0
sum_postura <- 0


# Traduccion index vec errores
index_mirada <- 1
index_profunda <- 2
index_inclinacion <- 3
index_manos_codos <- 4
index_manos_pendiente <- 5
index_pies <- 6
index_postura <- 7

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

#Funcion compracion relacion > tolerancia
comparar <- function(mayor, menor) {
  ret <- 0
  if (mayor > menor) {
    ret <-  1
  }
  return(ret)
}


#Matriz de Numericos
numeric_vec <- numeric(nrow(dataframe) * ncol(dataframe))  # tamaño total
index <- 1

debug_var <- 0
# Ejecucion de las reglas por frame
for (fila in 1:nrow(dataframe)) {

  for (col in 1:ncol(dataframe)) {
    # Convertir cada valor a numeric y guardarlo en numeric_vec
    numeric_vec[index] <- as.numeric(dataframe[fila, col])
    index <- index + 1
  }
  pos <- function(coord) {
    return(numeric_vec[coord])
  }
  # vec_debug[fila] <- numeric_vec[pos(x13)]
  
  # primer frame
  if(fila == 1) {
    dist_hombro_cadera <- abs((pos(x11) - pos(x23))**2 + ((1-(1-pos(y11))) - (1-pos(y23)))**2)
  }

  vec_timestamps[fila]  <-  numeric_vec[1]

  m_espalda <- ((1-pos(y23)) - (1-pos(y11))) / (pos(x23) - pos(x11))
  m_cuello <- ((1-pos(y11)) - (1-pos(y7))) / (pos(x11) - pos(x7))

  res <- comparar(abs((1-pos(y2)) - (1-pos(y7))), 0.018)
  vec_mirada[fila] <- res
  sum_mirada <- sum_mirada + res

  res <- comparar((1-pos(y25)) - (1-pos(y23)), (-0.01))
  vec_profunda[fila] <- res
  sum_profunda <- sum_profunda + res

  res <- comparar((-0.1), pos(x11) - pos(x25))
  vec_inclinacion[fila] <- res
  sum_inclinacion <- sum_inclinacion + res

  res <- comparar(abs(pos(x13) - pos(x15)), 0.05)
  if(res == 1 && pos(x13) - pos(x15) < 0) {
    vec_manos_codos[fila] <- res
    sum_manos_codos <- sum_manos_codos + res
  }

  res <- comparar((1-pos(y13)) - (1-pos(y11)), 1) #Codo hombro
  vec_manos_pendiente[fila] <- res
  sum_manos_pendiente <- sum_manos_pendiente + res

  res <- comparar(abs((1-pos(y31)) - (1-pos(y29))), 0.04)
  vec_pies[fila] <- res
  sum_pies <- sum_pies + res

  #No implementado por complejidad
  # m_cadera_hombros <- ((1-pos(y11)) - (1-pos(y23))) / (pos(x11) - pos(x23))
  # m_cadera_oreja <- ((1-pos(y7)) - (1-pos(y23))) / (pos(x7) - pos(x23))
  # if(abs(m_cadera_hombros) < 2 && abs(m_cadera_oreja) < 2) {
  #   debug_var <- debug_var + 1
  #   res <- comparar((m_cadera_hombros - m_cadera_oreja), 0.2)
  #   vec_postura[fila] <- res
  #   sum_postura <- sum_postura + res
  # }
  # else{
  #   vec_postura[fila] <- 0
  # }
  vec_postura[fila] <- 0


  # reset index to 1 for next row
  index <- 1
}

#Determinaciones

determinarFramesErrados <- function(index, suma, tolerancia) {
  if(suma > tolerancia) {
    vec_errores[index] <<- 1
  }
}

determinarFramesCorrectos <- function(index, suma, tolerancia) {
  if(suma < tolerancia) {
    vec_errores[index] <<- 1
  }
}

#Mensajes de salida de problemas

determinarFramesErrados(index_mirada, sum_mirada, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén la cabeza y la mirada rectas, paralelas al suelo.”)

determinarFramesCorrectos(index_profunda, sum_profunda, 1)
#cat(“Se detectó un problema durante el ejercicio: La sentadilla no es profunda. Para hacer una sentadilla profunda debes bajar la cadera por debajo de la altura de las rodillas.”)

determinarFramesErrados(index_inclinacion, sum_inclinacion, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: No inclines el tronco por delante de las rodillas.”)

determinarFramesErrados(index_manos_codos, sum_manos_codos, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)

determinarFramesErrados(index_manos_pendiente, sum_manos_pendiente, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)

determinarFramesErrados(index_pies, sum_pies, 0)
#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén los pies planos y bien apoyados en el suelo.”)

determinarFramesErrados(index_postura, sum_postura, 0)

# Crear vector de sumas y asignar cada suma a su índice correspondiente
vec_sumas <- numeric(length(vec_errores))
vec_sumas[index_mirada] <- sum_mirada
vec_sumas[index_profunda] <- sum_profunda
vec_sumas[index_inclinacion] <- sum_inclinacion
vec_sumas[index_manos_codos] <- sum_manos_codos
vec_sumas[index_manos_pendiente] <- sum_manos_pendiente
vec_sumas[index_pies] <- sum_pies
vec_sumas[index_postura] <- sum_postura

# Crear objeto de salida y reasignar a vec_sumas para que el return devuelva el objeto
vec_res <- list(vec_errores = vec_errores, vec_sumas = vec_sumas, debug_var = debug_var)
return(vec_res)
}

# Ejecutar función
resultado  <-  func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado  <-  resultado)), "\n")
flush.console()
