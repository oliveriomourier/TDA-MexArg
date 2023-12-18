using Pkg

using CSV
using DataFrames
using Plots
using Dates

new_df = CSV.read("sptfy_top_50.csv", DataFrame)

function filterDanceability(df, respuestaUser)
    BAILABILIDAD_ALTA = 0.79
    BAILABILIDAD_BAJA = 0.65

    if(respuestaUser == "ALTA")
        df = filter(r -> r.danceability >= BAILABILIDAD_ALTA, df)
    elseif(respuestaUser == "MEDIA")
        df = filter(r -> BAILABILIDAD_ALTA > r.danceability >= BAILABILIDAD_BAJA, df)
    elseif(respuestaUser == "BAJA")
        df = filter(r -> BAILABILIDAD_BAJA > r.danceability, df)
    end

    return df
end

function filterEnergy(df, respuestaUser)
    ENERGIA_ALTA = 0.8
    ENERGIA_BAJA = 0.7
    
    if(respuestaUser == "ALTA")
        df = filter(r -> r.energy >= ENERGIA_ALTA, df)
    elseif(respuestaUser == "MEDIA")
        df = filter(r -> ENERGIA_ALTA > r.energy >= ENERGIA_BAJA, df)
    elseif(respuestaUser == "BAJA")
        df = filter(r -> ENERGIA_BAJA > r.energy, df)
    end

    return df
end

function filterLoudness(df, respuestaUser)
    LOUDNESS_ALTA = -0.4
    LOUDNESS_BAJA = -0.7
    cantidadRegistros = size(df, 1)
    i = 1

    df_response = DataFrame(name=String[], artists= String[], danceability=Float64[], energy=Float64[], loudness=Float64[])

    while i <= cantidadRegistros
        nombre = df[i, :name]
        artista = df[i, :artists]
        danceability = df[i, :danceability]
        energy = df[i, :energy]
        loudness = df[i, :loudness]

        if(df[i, :loudness] > LOUDNESS_ALTA && respuestaUser == "ALTA")
            push!(df_response, (nombre, artista, danceability, energy, loudness))

        elseif(LOUDNESS_ALTA > df[i, :loudness] > LOUDNESS_BAJA && respuestaUser == "MEDIA")
            push!(df_response, (nombre, artista, danceability, energy, loudness))
        
        elseif(LOUDNESS_BAJA >= df[i, :loudness] && respuestaUser == "BAJA")
            push!(df_response, (nombre, artista, danceability, energy, loudness))

        end

        i += 1
    end

    return df_response
end

function main()
    df_topMundial = new_df[1:50, :]

    df_filter = filterEnergy(df_topMundial, "MEDIA")
    df_filter = filterDanceability(df_filter, "MEDIA")
    df_filter = filterLoudness(df_filter, "BAJA")

    return df_filter[:, [:name, :danceability, :energy, :loudness]]   
end
main()

function main2()
    df_topMundial = new_df[1:50, :]

    df_filter = filterEnergy(df_topMundial, "BAJA")
    df_filter = filterDanceability(df_filter, "MEDIA")
    df_filter = filterLoudness(df_filter, "BAJA")

    return df_filter[:, [:name, :danceability, :energy, :loudness]]   
end
main2()

function main3()
    df_topMundial = new_df[1:50, :]

    df_filter = filterEnergy(df_topMundial, "ALTA")
    df_filter = filterDanceability(df_filter, "ALTA")
    df_filter = filterLoudness(df_filter, "BAJA")

    return df_filter[:, [:name, :danceability, :energy, :loudness]]   
end
main3()

function proceso1()
    println("Inicio de proceso 1")
    sleep(5)  # Simulacion de tiempo
    println("Fin de proceso 1")
end

function proceso2()
    println("Inicio de proceso 2")
    sleep(2)  # Simulacion de tiempo
    println("Fin de proceso 2")
end

# Crear threads para ejecutar los procesos en paralelo
t1 = Threads.@spawn proceso1()
t2 = Threads.@spawn proceso2()

# Esperar a que ambos threads terminen
Threads.wait(t1)
Threads.wait(t2)
