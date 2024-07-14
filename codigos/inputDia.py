# Solicitar al usuario que ingrese una calificación para su día
calificacion = int(input("Por favor, ingrese una calificación del 1 al 10 para su día: "))

# Validar que la calificación esté dentro del rango válido
if calificacion < 1 or calificacion > 10:
    print("La calificación ingresada no es válida. Por favor, ingrese un número del 1 al 10.")
else:
    # Realizar alguna acción basada en la calificación ingresada
    if calificacion <= 5:
        print("Lo siento, parece que tu día no fue tan bueno.")
    elif calificacion <= 8:
        print("Tu día estuvo bien, ¡pero seguro puede mejorar!")
    else:
        print("¡Excelente! Parece que tu día fue genial.")
