; =========================================================
; TAREA I - MICROPROCESADORES
; Programa para Z80 Workbench
; =========================================================

        .ORG    0000H       ; Inicia en la memoria de código (EEPROM)

START:
        LD      SP, 0F7FFH  ; Inicializar el Puntero de Pila (Stack Pointer) en la SRAM

        ; a. Solicitar nombre y apellidos
        LD      HL, MSG_PROMPT
        CALL    PRINT_STR

        ; Inicializar el registro B como nuestro contador de letras
        LD      B, 0        

LEER_TECLA:
        CALL    RXA         ; b. Leer carácter tecleado
        CALL    TXA         ; Imprimir el carácter en pantalla (eco)

        CP      0DH         ; ¿Se presionó la tecla Enter (Retorno de carro)?
        JR      Z, FIN_LECTURA

        CP      20H         ; ¿Es un Espacio?
        JR      Z, LEER_TECLA ; Si es espacio, vuelve a leer sin contar

        ; c. Validar si es una letra mayúscula (A-Z = 41H a 5AH)
        CP      41H
        JR      C, ERROR_CHAR ; Si es menor a 'A', es un carácter inválido
        CP      5BH
        JR      C, ES_LETRA   ; Si es menor a '[', entonces es una letra mayúscula válida

        ; c. Validar si es una letra minúscula (a-z = 61H a 7AH)
        CP      61H
        JR      C, ERROR_CHAR ; Si es menor a 'a', es inválido
        CP      7BH
        JR      NC, ERROR_CHAR; Si es mayor o igual a '{', es inválido

ES_LETRA:
        ; d. Contar el número de letras
        INC     B           ; Incrementamos el contador
        JR      LEER_TECLA  ; Volver a leer la siguiente tecla

ERROR_CHAR:
        ; c. Enviar mensaje de error si se teclea algo diferente
        LD      HL, MSG_ERROR
        CALL    PRINT_STR
        HALT                ; Detener el procesador

FIN_LECTURA:
        ; e. Mostrar texto final
        LD      HL, MSG_RES
        CALL    PRINT_STR
        
        ; Mostrar la cantidad de letras
        LD      A, B
        CALL    PRINT_NUM
        
        HALT                ; Fin del programa exitoso

; =========================================================
; Rutinas de Entrada / Salida (Compatibles con Z80 Workbench)
; =========================================================

PRINT_STR:
        LD      A, (HL)     ; Cargar el carácter actual
        OR      A           ; ¿Llegamos al final del string (00H)?
        RET     Z           ; Si es 0, regresar
        CALL    TXA         ; Imprimir carácter
        INC     HL          ; Apuntar al siguiente carácter
        JR      PRINT_STR

RXA:
WAIT_RX:
        IN      A, (02H)    ; Leer estado del puerto serial virtual
        CP      00H         ; ¿Hay dato disponible?
        JR      Z, WAIT_RX  ; Si es 0, seguir esperando
        IN      A, (01H)    ; Leer el dato tecleado
        RET

TXA:
        OUT     (01H), A    ; Enviar el carácter a la pantalla
        RET

PRINT_NUM:
        ; Subrutina básica para imprimir el número de letras (0-99)
        LD      C, 0        ; Contador de decenas
RESTA_10:
        CP      10
        JR      C, IMPRIME_DECENAS
        SUB     10
        INC     C
        JR      RESTA_10
IMPRIME_DECENAS:
        PUSH    AF          ; Guardar el residuo (unidades)
        LD      A, C
        ADD     A, '0'      ; Convertir decenas a carácter ASCII
        CALL    TXA         ; Imprimir decenas
        POP     AF          ; Recuperar unidades
        ADD     A, '0'      ; Convertir unidades a carácter ASCII
        CALL    TXA         ; Imprimir unidades
        RET

; =========================================================
; Datos y Mensajes
; =========================================================
MSG_PROMPT: .BYTE   0CH, "Ingrese su nombre y apellidos: ", 0
MSG_ERROR:  .BYTE   0DH, 0AH, "ERROR: Caracter invalido tecleado.", 0DH, 0AH, 0
MSG_RES:    .BYTE   0DH, 0AH, "Cantidad de letras: ", 0

        .END