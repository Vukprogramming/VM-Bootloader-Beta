BITS 16
ORG 0x7C00

start:
    call boot_clear_screen

    mov si, message
    call print_string

main_loop:
    mov si, user_input
    call get_input_loop

    mov ax, ds
    mov es, ax

    mov si, user_input        
    mov di, vm_ver_cmd        
    call compare_strings
    cmp ax, 1                  
    je VM_ver

    mov si, user_input
    mov di, shut_down_cmd
    call compare_strings
    cmp ax, 1
    je shut_down

    mov si, user_input
    mov di, clear_screen_cmd
    call compare_strings
    cmp ax, 1
    je clear_screen

    mov si, invalid_cmd_str
    call print_string
    jmp main_loop

VM_ver:
    mov si, vm_ver_cmd_str
    call print_string
    jmp main_loop

print_string:
    lodsb
    cmp al, 0
    je done_print_string
    mov ah, 0x0E
    int 0x10
    jmp print_string

done_print_string:
    ret

get_input_loop:
    call get_key
    cmp al, 8
    je handle_backspace
    mov ah, 0x0E
    int 0x10
    cmp al, 0x0D              
    je done_input
    mov [si], al
    inc si
    jmp get_input_loop

done_input:
    mov byte [si], 0          
    ret
    jmp get_input_loop

handle_backspace:
    mov al, 8
    mov ah, 0x0E
    int 0x10

    mov al, ' '
    mov ah, 0x0E
    int 0x10
    
    mov al, 8
    mov ah, 0x0E
    int 0x10

    dec si
    jmp get_input_loop

done:
    jmp $

get_key:
    mov ah, 0x00
    int 0x16
    ret

compare_strings:

compare_loop:
    lodsb                      
    scasb                    
    jne not_equal              
    cmp al, 0                    
    je equal                    
    jmp compare_loop            

equal:
    mov ax, 1                    
    ret

not_equal:
    xor ax, ax                   
    ret

message:
    db 'VM OS::BOOT SUCCESFUL', 13, 10
    db 'Welcome to VM OS :)', 13, 10
    db '', 13, 10
    db '', 0
    
shut_down:
    mov al, 0x00
    out 0xF4, al
    hlt

clear_screen_cmd:
    db 'cls', 0

clear_screen:
    mov ah, 0x06           
    mov al, 0              
    mov bh, 0x07          
    mov cx, 0              
    mov dx, 0x184F         
    int 0x10

    mov ah, 0x02           
    mov bh, 0              
    mov dh, 0              
    mov dl, 0              
    int 0x10

    mov ah, 0x01           
    mov cx, 0x0607         
    int 0x10

    jmp main_loop

boot_clear_screen:
    mov ah, 0x06           
    mov al, 0              
    mov bh, 0x07          
    mov cx, 0              
    mov dx, 0x184F         
    int 0x10

    mov ah, 0x02           
    mov bh, 0              
    mov dh, 0              
    mov dl, 0              
    int 0x10

    mov ah, 0x01           
    mov cx, 0x0607         
    int 0x10

    ret

vm_ver_cmd:
    db 'VM --ver', 0

shut_down_cmd:
    db 'pwr> 0', 0

echo_cmd:
    db 'echo', 0

vm_ver_cmd_str:
    db '', 10, 13
    db '', 10, 13
    db 'OS: VM OS', 13, 10
    db 'VM Version: VM OS 1.00 (Beta)', 13, 10
    db '', 10, 13
    db '', 0

user_input:
    db 50 dup(0)

invalid_cmd_str:
    db '', 10, 13
    db '', 10, 13
    db '', 10, 13
    db 'Error: Invalid Command', 13, 10
    db '', 10, 13
    db '', 0

times 510-($-$$) db 0
dw 0xAA55
