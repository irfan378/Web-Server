.intel_syntax noprefix
.globl _start

.section .text

_start:

# create a socket
mov rdi,2
mov rsi,1
mov rdx,0
mov rax,0x29
syscall

#bind the address

mov rdi,3
lea rsi,[rip+sockaddr]
mov rdx,16
mov rax,0x31
syscall

# listen

mov rdi,3
mov rsi,0
mov rax,50
syscall

#accept the connection
accept_loop:
mov rdi,3
mov rsi,0
mov rdx,0
mov rax,43
syscall


# fork the process
mov rax,57
syscall
mov rdi,rax
# go to the child process
cmp rax,0
je child

parent:
# close the  process
mov rdi,4
mov rbx,rdi
mov rax,3
syscall
jmp accept_loop




child:
# close the  process
mov rdi,3
mov rax,3
syscall


# read request
mov rdi,4
mov rsi,rsp
mov rdx,500
mov rax,0
syscall
mov r14,rax

# check wheather it is a get request
mov r10,rsp
get_loop:
mov al,[r10]
cmp al,0x47
je get
add r10,1



#open the path
mov r10,rsp
loop:
mov al,[r10]
cmp al,' '
je done
add r10,1
jmp loop

# write response
done:
add r10,1
mov r11,r10
mov r12,0

loop2:
mov al,[r11]
cmp al,' '
je done2
add r11,1
add r12,1
jmp loop2

done2:
mov byte ptr[r11],0


# open the file
mov rdi,r10
mov rsi,65
mov rdx,0777
mov rax,2
syscall

mov r10,rsp
mov r12,0
loop3:
mov eax,[r10]
cmp eax,0x0a0d0a0d
je done3
add r10,1
add r12,1
jmp loop3

done3:
sub r14,r12
add r10,4
sub r14,4

# write the file
write:
mov rdi,3
mov rsi,r10
mov rdx,r14
mov rax,1
syscall

# close the file
mov rdi,3
mov rax,3
syscall
jmp http_resp2

# write http response
http_resp2:
mov rdi,4
lea rsi,message
mov rdx,19
mov rax,1
syscall
jmp exit

get:
#open the path
mov r10,rsp
loop10:
mov al,[r10]
cmp al,' '
je done10
add r10,1
jmp loop10

done10:
add r10,1
mov r11,r10
mov r12,0

loop20:
mov al,[r11]
cmp al,' '
je done20
add r11,1
add r12,1
jmp loop20

done20:
mov byte ptr[r11],0

#open the file
mov rdi,r10
mov rsi,0
mov rax,2
syscall

#read from file
mov rdi,rax
mov rsi,rsp
mov rdx,500
mov rax,0
syscall
mov r10,rax
# close the  process
mov rdi,3
mov rax,3
syscall

# write http response
http_resp:
mov rdi,4
lea rsi,message
mov rdx,19
mov rax,1
syscall

# write the contents of a file
mov rdi,4
mov rsi,rsp
mov rdx,r10
mov rax,1
syscall



#exit the program
exit:
mov rdi,0
mov rax,60
syscall

.section .data
sockaddr:
.2byte 2
.byte 0
.byte 0x50
.4byte 0
.8byte 0
message:
  .ascii "HTTP/1.0 200 OK\r\n\r\n"
backslash:
  .ascii "0x5c"


