using Plots
using StatsBase
using DataFrames
using CSV
using Pkg
using Clustering
using Statistics
using GLM

# MATRICES Y VECTORES

matriz = [7 8 9;
          6 5 4]

vector = [1, 2, 3]

matriz * vector

#---------------------------------
# BDD: SPOTIFY SONGS
data = CSV.read("C:/Users/oscar/Documents/ITESO/Septimo Semestre UBA/Teoría de lenguaje/tp_julia/universal_top_spotify_songs.csv", DataFrame)

# Visualización básica
# Histograma de la popularidad (variable principal)
histogram(data.popularity, bins=20, xlabel="Popularidad",
    ylabel="Frecuencia", title="Histograma de Popularidad")

columnas_clave = [:daily_movement, :weekly_movement, :popularity, :is_explicit, :duration_ms, 
    :danceability, :energy, :loudness, :speechiness, :acousticness, :instrumentalness, :liveness, :valence,
    :tempo, :time_signature]


#-------------------------
# Análisis de estadísticas descriptivas
describe_cc = describe(data[:, columnas_clave])
describe_cc


#------------------------------
#Histogramas
# Configurar el tamaño de la figura general
plot_size = (1000, 800)  # Puedes ajustar estos valores según tus necesidades

# Crear histogramas para las columnas seleccionadas con tamaño personalizado
histogramas = [histogram(data[:, col], bins=20, xlabel=string(col), ylabel="Frecuencia", legend=false, size=plot_size) for col in columnas_clave]

# Calcular el número de filas y columnas necesarias
num_filas = div(length(columnas_clave), 2)
num_columnas = ceil(Int, length(columnas_clave) / num_filas)

# Mostrar los histogramas en filas de dos
plot(histogramas..., layout=(num_filas, num_columnas))



#--------------------------------------------------------------
# Descubrir patrones de popularidad
# Correlación entre las diferentes variables y la popularidad
correlation_matrix = cor(Matrix(data[:, [:popularity, :danceability, :energy, :loudness, 
                :duration_ms, :speechiness, :acousticness, :liveness]]))



#--------------------------------------------
# Análisis de movimientos diarios y semanales
println("Análisis de Movimientos Diarios:")
describe(data.daily_movement)

println("\nAnálisis de Movimientos Semanales:")
describe(data.weekly_movement)

# Calcular el promedio de valores positivos
promedio_positivos = mean(data[data.daily_movement .> 0, :daily_movement], dims=1)

# Calcular el promedio de valores negativos
promedio_negativos = mean(data[data.daily_movement .< 0, :daily_movement], dims=1)

# Mostrar los resultados
println("Promedio de valores positivos: ", promedio_positivos[1])
println("Promedio de valores negativos: ", promedio_negativos[1])



#------------------------------------------------------------------
#### Calcular el promedio de la popularidad por fecha usando combine
mean_popularity_over_time = combine(groupby(data, :snapshot_date), :popularity => mean => :mean_popularity)

# Mostrar el resultado
println(mean_popularity_over_time)

# Gráfico de línea para mostrar el promedio de popularidad a lo largo del tiempo
plot(mean_popularity_over_time.snapshot_date, mean_popularity_over_time.mean_popularity, xlabel="Fecha", 
    ylabel="Popularidad Promedio", title="Popularidad Promedio a lo largo del Tiempo", label="Popularidad", fmt=:png)



function kmeans_clustering(data::DataFrame, features::Tuple{Symbol, Symbol}, num_clusters::Int)
    # Extraemos las características de la data
    caracteristicas = select(data, features...)

    # Realizamos el agrupamiento utilizando K-means
    resultados_kmeans = kmeans(Matrix(caracteristicas)', num_clusters)

    # Obtenemos las etiquetas de cluster asignadas a cada punto de datos
    etiquetas_clusters = resultados_kmeans.assignments

    # Visualizamos los datos agrupados por colores
    scatter(caracteristicas[!, features[1]], caracteristicas[!, features[2]], group=etiquetas_clusters,
        xlabel=string(features[1]), ylabel=string(features[2]), 
        title="$(features[1]) - $(features[2])")


    # Muestra los centros de los clusters como círculos rojos
    scatter!(resultados_kmeans.centers[1, :], resultados_kmeans.centers[2, :], color=:red, markersize=10, label="Centros de Clusters")
end

#Popularity - Danceability
#kmeans_clustering(data, (:popularity, :danceability), 2)

#Popularity - Energy 
#kmeans_clustering(data, (:popularity, :energy), 2)

#Popularity - Duration_ms
#kmeans_clustering(data, (:popularity, :duration_ms), 2)

#Popularity - Loudness
#kmeans_clustering(data, (:popularity, :loudness), 2)


#-----------------------------------------------------------
#MUESTREO DE DATOS
function kmeans_clustering(data::DataFrame, features::Tuple{Symbol, Symbol}, num_clusters::Int)
    # Muestreo aleatorio de datos
    indices_muestreo = sample(1:nrow(data), min(1000, nrow(data)), replace=false)
    data_muestreada = data[indices_muestreo, :]

    # Extraemos las características de la data
    caracteristicas = select(data_muestreada, features...)

    # Resto del código sigue igual
    resultados_kmeans = kmeans(Matrix(caracteristicas)', num_clusters)
    etiquetas_clusters = resultados_kmeans.assignments

    scatter(caracteristicas[!, features[1]], caracteristicas[!, features[2]], group=etiquetas_clusters,
        xlabel=string(features[1]), ylabel=string(features[2]), 
        title="$(features[1]) - $(features[2])")

    scatter!(resultados_kmeans.centers[1, :], resultados_kmeans.centers[2, :], color=:red, markersize=10, label="Centros de Clusters")
end

kmeans_clustering(data, (:popularity, :danceability), 2)

#------------------------------------------------------
#PLOT INTERACTIVO
using PlotlyJS

function kmeans_clustering_interactivo(data::DataFrame, features::Tuple{Symbol, Symbol}, num_clusters::Int)
    # Muestreo aleatorio de datos
    indices_muestreo = sample(1:nrow(data), min(1000, nrow(data)), replace=false)
    data_muestreada = data[indices_muestreo, :]

    # Extraemos las características de la data
    caracteristicas = select(data_muestreada, features...)

    # Resto del código sigue igual
    resultados_kmeans = kmeans(Matrix(caracteristicas)', num_clusters)
    etiquetas_clusters = resultados_kmeans.assignments

    # Cambia a un gráfico interactivo con PlotlyJS
    plotly()
    scatter(caracteristicas[!, features[1]], caracteristicas[!, features[2]], group=etiquetas_clusters,
        xlabel=string(features[1]), ylabel=string(features[2]), 
        title="$(features[1]) - $(features[2])")

    scatter!(resultados_kmeans.centers[1, :], resultados_kmeans.centers[2, :], color=:red, markersize=10, label="Centros de Clusters")
end

kmeans_clustering_interactivo(data, (:popularity, :danceability), 2)

#-----------------------------------------------------------------
#FILTRAR POR PAÍS
#Argentina (AR)

# Filtrar por país ('AR' en este caso), excluyendo valores Missing
data_ar = filter(row -> coalesce(get(row, :country, missing), "") == "AR", data)

# Visualización básica
# Histograma de la popularidad
histogram(data_ar.popularity, bins=20, xlabel="Popularidad",
    ylabel="Frecuencia", title="Histograma de Popularidad")

# Descubrir patrones de popularidad
# Correlación entre las diferentes variables y la popularidad
correlation_matrix = cor(Matrix(data_ar[:, [:popularity, :danceability, :energy, :loudness, 
                :duration_ms, :speechiness, :acousticness, :liveness]]))



kmeans_clustering_interactivo(data_ar, (:popularity, :danceability), 1)


#--------------------------------------------------------------
#Mexico (MX)

# Filtrar por país ('MX' en este caso), excluyendo valores Missing
data_mx = filter(row -> coalesce(get(row, :country, missing), "") == "MX", data)

# Visualización básica
# Histograma de la popularidad
histogram(data_mx.popularity, bins=20, xlabel="Popularidad",
    ylabel="Frecuencia", title="Histograma de Popularidad")

#Descubrir patrones de popularidad
# Correlación entre las diferentes variables y la popularidad
correlation_matrix = cor(Matrix(data_mx[:, [:popularity, :danceability, :energy, :loudness, 
                :duration_ms, :speechiness, :acousticness, :liveness]]))

kmeans_clustering_interactivo(data_mx, (:popularity, :acousticness), 1) 



#----------------------------------------
#FUNCIONES ANONIMAS
# Sintaxis general de una función anónima
f = x -> x^2

# Uso de la función anónima
resultado = f(3)  

# También se pueden utilizar directamente en lugar de asignarlas a una variable
resultado_2 = (x -> x^3)(2)  


#-------------------------------------------
#MULTIPLE DISPATCH

methods(+)

@which 3 + 3

@which 3.0 + 3.0    

@which 3 + 3.0

import Base: +

+(x::String, y::String) = string(x, y)

"hello " + "world!"

@which "hello " + "world!"

#--------------------------------------------------------
#MACROS

macro sayhello(name)
    return :(println("Hello, ", $name, "!"))
end

@sayhello "Julia"

@time begin
    correlation_matrix = cor(Matrix(data_mx[:, [:popularity, :danceability, :energy, :loudness, 
                :duration_ms, :speechiness, :acousticness, :liveness]]))
end

@allocated begin
    correlation_matrix = cor(Matrix(data_mx[:, [:popularity, :danceability, :energy, :loudness, 
                :duration_ms, :speechiness, :acousticness, :liveness]]))
end

#------------------------------------------------------------------
#REGRESION LINEAL
# Crear el modelo de regresión lineal
regresion_ar = lm(@formula(danceability ~ popularity), data_ar)

# Obtener resumen del modelo
println("Resumen del modelo:")
println(summary(regresion_ar))

# Graficar el resultado de la regresión
scatter(data_ar.popularity, data_ar.danceability, label="Datos")
plot!(data_ar.popularity, predict(regresion_ar), label="Regresión Lineal", 
    xlabel="Popularity", ylabel="Danceability", legend=:top)



# Crear el modelo de regresión lineal
regresion_mx = lm(@formula(acousticness ~ popularity), data_mx)

# Obtener resumen del modelo
println("Resumen del modelo:")
println(summary(regresion_mx))

# Graficar el resultado de la regresión
scatter(data_mx.popularity, data_mx.acousticness, label="Datos")
plot!(data_mx.popularity, predict(regresion_mx), label="Regresión Lineal", 
    xlabel="Popularity", ylabel="Acousticness", legend=:top)


#-------------------------------------------------------
#DISTRIBUIDOS
# Paso 1: Iniciar el sistema distribuido
using Distributed
addprocs(4)  # Agregar 4 procesos (puedes ajustar según el número de núcleos en tu máquina)

# Paso 2: Cargar el paquete en todos los procesos
@everywhere using Distributed

# Paso 3: Función que imprime mensajes desde diferentes procesos
@everywhere function imprimir_mensaje(id::Int)
    println("Proceso $id: Hola desde el proceso $(myid())")
end

# Paso 4: Llamar a la función en paralelo
@distributed for i in 1:nprocs()
    imprimir_mensaje(i)
end

#----------------------------
#MANEJO DE MEMORIA

# Crear un vector de enteros
vector_enteros = [1, 2, 3, 4, 5]

# Obtener el tamaño del vector en bytes
tamaño_en_bytes = sizeof(vector_enteros)
println("Tamaño del vector en bytes: $tamaño_en_bytes")

# Modificar el vector
push!(vector_enteros, 6)

# Obtener el nuevo tamaño del vector en bytes
nuevo_tamaño_en_bytes = sizeof(vector_enteros)
println("Nuevo tamaño del vector en bytes: $nuevo_tamaño_en_bytes")

#----------------------------
#Recolector de basura

# Crear una función que genera basura (un vector temporal)
function generar_basura()
    basura = rand(1:100, 1000)
    return sum(basura)
end

# Crear una función principal que utiliza la función que genera basura
function funcion_principal()
    resultado = generar_basura()
    println("Resultado: $resultado")
end

# Obtener el uso de memoria antes de la ejecución
memoria_inicial = Sys.free_memory()
println("Uso de memoria antes de la ejecución: $memoria_inicial bytes")

# Llamar a la función principal
funcion_principal()

# Obtener el uso de memoria después de la ejecución
memoria_despues = Sys.free_memory()
println("Uso de memoria después de la ejecución: $memoria_despues bytes")

# Forzar la recolección de basura
GC.gc()

# Obtener el uso de memoria después de la recolección de basura
memoria_despues_gc = Sys.free_memory()
println("Uso de memoria después de la recolección de basura: $memoria_despues_gc bytes")

#------------------------
#Limpiar objetos innecesarios
x = rand(10^6)
# Al terminar de usar x
x = nothing  # Liberar la memoria

#------------------------
#PLUTO