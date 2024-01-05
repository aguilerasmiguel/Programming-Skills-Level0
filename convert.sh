#!/bin/bash

# Definimos la moneda base, en este caso será el USD 
moneda_base="USD"

# Definimos las tasas relativas de cambio de cada moneda frente a la moneda base
# Esto lo hacemos para no tener que estar declarando todos los pares aunque no es exacto
# y puede traer algún problema de spread (oferta-demanda)  sirve para dar alguna idea
# Convertir primero a usd y luego a la moneda en cuestión no será exacto pero para fines prácticos puede funcionar

declare -A tasas
tasas["USD"]=1
tasas["CLP"]=887
tasas["ARS"]=811.75
tasas["EUR"]=0.91
tasas["GBP"]=0.79
tasas["TRY"]=29.76

# Definir límites mínimos y máximos para cada moneda
declare -A limites_minimos
declare -A limites_maximos

limites_minimos["USD"]=10
limites_maximos["USD"]=1004000

limites_minimos["CLP"]=5000
limites_maximos["CLP"]=500000

limites_minimos["ARS"]=10000
limites_maximos["ARS"]=1000000

limites_minimos["EUR"]=3000
limites_maximos["EUR"]=450000

limites_minimos["GBP"]=100
limites_maximos["GBP"]=1340000

limites_minimos["TRY"]=1000
limites_maximos["TRY"]=104000


# Definir la función que convertirá los pares de monedas
convertir_moneda() {

    local moneda_origen=$(echo $1 | tr '[:lower:]' '[:upper:]')  # Convertir a mayúsculas
    local moneda_destino=$(echo $2 | tr '[:lower:]' '[:upper:]') # Convertir a mayúsculas
    local cantidad=$3

    # Ahora vamos a convertir primero a la moneda base en este caso USD y luego a la moneda destino, usamos awk porque bash no maneja punto flotante
    # también podríamos haber utilizado bc pero este no viene instalado por defecto mientras awk si. 
    local cantidad_convertida_base=$(awk "BEGIN {print $cantidad / ${tasas[$moneda_origen]}}")
    local cantidad_convertida_destino=$(awk "BEGIN {print $cantidad_convertida_base * ${tasas[$moneda_destino]}}")

    echo "$cantidad_convertida_destino"
}

menu_principal() {

   echo "Bienvenido a este inexacto pero entretenido convertidor"
    echo "Escoja su moneda origen:"
    read -p "CLP, ARS, USD, EUR, TRY, or GBP: " moneda_origen
    moneda_origen=$(echo $moneda_origen | tr '[:lower:]' '[:upper:]') # Convertir a mayúsculas

    echo "A cuál moneda va a convertir?"
    read -p "CLP, ARS, USD, EUR, TRY, or GBP: " moneda_destino
    moneda_destino=$(echo $moneda_destino | tr '[:lower:]' '[:upper:]') # Convertir a mayúsculas

    # Comprobar si las monedas están definidas en el arreglo tasas
    if [[ ! ${tasas[$moneda_origen]} || ! ${tasas[$moneda_destino]} ]]; then
        echo "Una o ambas monedas no están definidas. Por favor, ingrese monedas válidas."
        return 1
    fi

    echo "Cuánto va a convertir $moneda_origen:"
    read cantidad

    # Verificar que la cantidad es un número
    if ! [[ $cantidad =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Por favor, ingrese una cantidad numérica válida."
        return 1
    fi

    # Comprobar si la cantidad está dentro de los límites antes de la conversión
    minimo=${limites_minimos[$moneda_origen]}
    maximo=${limites_maximos[$moneda_origen]}

    if [[ $cantidad -lt $minimo || $cantidad -gt $maximo ]]; then
        echo "La cantidad a convertir debe estar entre $minimo y $maximo $moneda_origen."
        return 1
    fi

    cantidad_convertida=$(convertir_moneda $moneda_origen $moneda_destino $cantidad)

    if [ $? -eq 0 ]; then
        echo "La cantidad convertida es: $cantidad_convertida $moneda_destino"

        echo "Quieres sacar la plata? (si/no)"
        read extraer
        if [ "$extraer" = "si" ]; then
            local mi_comision=$(awk "BEGIN {print $cantidad_convertida * 0.01}")
            local cantidad_final_cliente=$(awk "BEGIN {print $cantidad_convertida - $mi_comision}")
            echo "Cantidad que ha extraído luego de la comisión del 1%: $cantidad_final_cliente $moneda_destino"
        fi
    fi

    echo "Deseas realizar otra operación? (si/no)"
    read otra_operacion
    if [ "$otra_operacion" = "si" ]; then
        menu_principal
    else
        echo "Gracias por usar mi inexacto convertidor."
        exit 0
    fi
}

menu_principal
