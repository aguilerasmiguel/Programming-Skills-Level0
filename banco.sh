#!/bin/bash

# Inicializar las credenciales del usuario y el balance
username="usuario1"
password="password"
balance=2000
intentos=0

# Definimos la función para cerrar la sesión
cerrar_sesion() { 
   echo "Sesión terminada exitosamente"
   exit 
}

# Definimos la función para mostrar el balance 
mostrar_balance() {
    echo "Balance actual: \$${balance}"
}

# Definimos la función para depositar
# ^[0-9]+(\.[0-9]+)?$: Esta expresión regular se usa para verificar si la entrada es un número positivo con o sin decimales
# ^ Se refiere al inicio de la línea 
# [0-9]+ Se refiere a uno o más dígitos desde el 0 hasta el 9. 
# (\.[0-9]+)? Es un grupo opcional que permite un punto decimal seguido de uno o más dígitos
# $ Se refiere al final de la línea
# Esto es útil para sanitizar los valores y evitar posibles errores en la ejecución del script 
depositar() {
    echo "Entre la cantidad a depositar: "
    read cantidad_depositar
    # Verifica si la cantidad es un número positivo con o sin decimales
    if ! [[ $cantidad_depositar =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Por favor ingrese un número positivo, con o sin decimales."
        return
    fi
    balance=$(awk "BEGIN {print $balance + $cantidad_depositar}") # Utilizamos awk que es una utilidad de linux para poder realizar operaciones de punto flotante en bash
    echo "El depósito ha sido acreditado a su cuenta"
    mostrar_balance
}

# Definimos la función para extraer
extraer() {
    echo "Entre la cantidad a extraer: "
    read cantidad_extraer
    # Verifica si la cantidad es un número positivo con o sin decimales
    if ! [[ $cantidad_extraer =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Por favor ingrese un número positivo, con o sin decimales."
        return
    fi
    if awk "BEGIN {exit !($cantidad_extraer <= $balance)}"; then
        balance=$(awk "BEGIN {print $balance - $cantidad_extraer}")
        echo "Fondos retirados correctamente"
    else
        echo "Fondos insuficientes"
    fi
    mostrar_balance
}

# Definimos la función para el menú de opciones
mostrar_menu() {
    echo "1. Mostrar balance actual"
    echo "2. Realizar depósitos"
    echo "3. Realizar extracciones"
    echo "4. Salir"
    echo "Seleccione una opción: "
    read option
    case $option in
        1) mostrar_balance ;;
        2) depositar ;;
        3) extraer ;;
        4) cerrar_sesion ;;
        *) echo "Opción inválida" ;;
    esac
}

# Definimos la función principal del sistema
funcion_principal() {
    while [ $intentos -lt 3 ]; do  # En bash lt significa "less than" o traducido al español "menor que" 
        echo "Usuario: "
        read entrada_usuario
        echo "Contraseña: "
        read -s entrada_password

        if [[ $entrada_usuario == $username && $entrada_password == $password ]]; then # En bash == (igualdad) es un operador de compración y && (and) otro. 
            echo "Acceso exitoso"
            while true; do
                mostrar_menu
            done
        else
            echo "Acceso denegado, usuario o contraseña incorrectos"
            intentos=$((intentos+1))
        fi
    done

    echo "Su cuenta ha sido bloqueada debido a que ha excedido el número máximo de intentos"
}

# Iniciar la función principal
funcion_principal
