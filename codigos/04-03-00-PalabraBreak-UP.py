# codigo sin break
for letra in 'Holanda':
    if letra == 'a':
        print(f'Letra encontrada: {letra}')

else:
    print('Fin ciclo for sin break')
    
print(f"--------------------------------------------------")
# codigo con break
for letra in 'Ecuador':
    if letra == 'a':
        print(f'Letra encontrada: {letra}')
        break
else:
    print('Fin ciclo for con break')
    