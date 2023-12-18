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

function pedirValorFiltrar(filtro)
    continuar = true
    
    while (continuar)
        println("Por favor, ingrese un valor para filtrar la columna: $filtro, los valores validos son: (ALTA, BAJA, MEDIA): ")
        respuesta_usuario = readline()
        respuesta_usuario = uppercase(strip(respuesta_usuario))

        if(respuesta_usuario == "ALTA" || 
            respuesta_usuario == "MEDIA" ||
            respuesta_usuario == "BAJA")
            continuar = false
        end
    end
    
    return respuesta_usuario
end

function main2()
    df_topMundial = new_df[1:50, :]

    valorEnergy = pedirValorFiltrar("energy")
    df_dance = filterEnergy(df_topMundial, valorEnergy)

    
    valorDanceability = pedirValorFiltrar("danceability")
    df_dance = filterDanceability(df_dance, valorDanceability)

    valorLoudness = pedirValorFiltrar("loudness")
    df_dance = filterLoudness(df_dance, valorLoudness)
    
    return df_dance[:, [:name, :danceability, :energy, :loudness]]
    
end

function main()
    respuesta_usuario = pedirValorFiltrar("danceability")
    println("Respuesta ingresada: $respuesta_usuario")
end

main()