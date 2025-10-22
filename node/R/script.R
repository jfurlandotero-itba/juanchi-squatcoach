# --- script.R ---
library(jsonlite)

# Leer JSON desde stdin
entrada  <-  fromJSON(file("stdin"))

# Definir función
func  <-  function(dataframe) {

# Cada  vec tiene n filas, donde n es la cantidad de frames en el dataframe
vec_timestamps  <-  numeric(nrow(data))
for (fila in 1:nrow(dataframe)) {
  vec_timestamps[fila]  <-  dataframe[fila, 1]
}

vec_pendiente_espalda_cuello  <-  numeric(nrow(data))
vec_mirada  <-  numeric(nrow(data))
vec_profunda  <-  numeric(nrow(data))
vec_inclinacion  <-  numeric(nrow(data))
vec_manos_hombros  <-  numeric(nrow(data))
vec_manos_codos  <-  numeric(nrow(data))
vec_manos_pendiente  <-  numeric(nrow(data))
vec_pies  <-  numeric(nrow(data))
vec_errores <- numeric(8)

# Traduccion index vec errores
index_mirada <- 1
index_pendiente_espalda_cuello <- 2
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

# Ejecucion de las reglas por frame
for (fila in 1:nrow(dataframe)) {
  m_espalda <- y23 - y11 / x23 - x11
  m_cuello <- (y11 - y7) / (x11 - x7)
  if (abs(m_espalda - m_cuello) > tolerancia) {
    vec_pendiente_espalda_cuello[fila]  <-  1
  } else {
    vec_pendiente_espalda_cuello[fila]  <-  0
  }
  if (abs(y2 - y7) > tolerancia) {
    vec_mirada[fila]  <-  1
  } else {
    vec_mirada[fila]  <-  0
  }
  if ((y25 - y23) >= 0) {
    vec_profunda[fila]  <-  1
  } else {
    vec_profunda[fila]  <-  0
  }
  if ((x11 - x25) >= 0) {
    vec_inclinacion[fila]  <-  1
  } else {
    vec_inclinacion[fila]  <-  0
  }
  if ((x15 - x11) > 0) {
    vec_manos_hombros[fila]  <-  1
  } else {
    vec_manos_hombros[fila]  <-  0
  }
  if ((x13 - x15) > 0) {
    vec_manos_codos[fila]  <-  1
  } else {
    vec_manos_codos[fila]  <-  0
  }
  if ((y11 - y13) >= 0) {
    vec_manos_pendiente[fila]  <-  1
  } else {
    vec_manos_pendiente[fila]  <-  0
  }
  if (abs(y31 - y29) > tolerancia) {
    vec_pies[fila]  <-  1
  } else {
    vec_pies[fila]  <-  0
  }
}
contador_frames_profunda  <-  0


# Mensajes de salida de problemas

for(frame in vec_timestamps) {
if(vec_pendiente_espalda_cuello[frame] == 1) {
  vec_errores[index_pendiente_espalda_cuello] <- 1
	#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: No encorves el cuello, alinea tu cuello y tu columna.”)
}

if( vec_mirada[frame] == 1) {
  vec_errores[index_mirada] <- 1
	#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén la cabeza y la mirada rectas, paralelas al suelo.”)
}

if( vec_profunda[frame] == 1) {
  vec_errores[index_profunda] <- 1
	contador_frames_profunda++
}

if( vec_inclinacion[frame] == 1) {
  vec_errores[index_inclinacion] <- 1
	#cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: No inclines el tronco por delante de las rodillas.”)
}

if( vec_manos_hombros[frame] == 1){
  vec_errores[index_manos_hombros] <- 1
  #cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)
}

if( vec_manos_codos[frame] == 1){
  vec_errores[index_manos_codos] <- 1
  #cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)
}

if( vec_manos_pendiente[frame] == 1){
  vec_errores[index_manos_pendiente] <- 1
  #cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: .”)
}

if( vec_pies[frame] == 1){
  vec_errores[index_pies] <- 1
  #cat(“Se detectó un problema en la marca de tiempo { vec_timestamps[frame]}: Mantén los pies planos y bien apoyados en el suelo.”)
}

}

if(contador_frames_profunda == 0) {
  vec_errores[index_profunda] <- 1
	#cat(“Se detectó un problema durante el ejercicio: La sentadilla no es profunda. Para hacer una sentadilla profunda debes bajar la cadera por debajo de la altura de las rodillas.”)
}
return(result)
}

# Ejecutar función
resultado  <-  func(entrada$valor)

# Enviar salida como JSON
cat(toJSON(list(resultado  <-  resultado)), "\n")
flush.console()
