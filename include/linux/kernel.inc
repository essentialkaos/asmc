; KERNEL.INC--
;
; Copyright (c) The Asmc Contributors. All rights reserved.
; Consult your license regarding permissions and restrictions.
;

.enum {
    SYS_READ                    = 0,    ; sys_read()
    SYS_WRITE                   = 1,    ; sys_write()
    SYS_OPEN                    = 2,    ; sys_open()
    SYS_CLOSE                   = 3,    ; sys_close()
    SYS_STAT                    = 4,    ; sys_newstat()
    SYS_FSTAT                   = 5,    ; sys_newfstat()
    SYS_LSTAT                   = 6,    ; sys_newlstat()
    SYS_POLL                    = 7,    ; sys_poll()
    SYS_LSEEK                   = 8,    ; sys_lseek()
    SYS_MMAP                    = 9,    ; sys_mmap()
    SYS_MPROTECT                = 10,   ; sys_mprotect()
    SYS_MUNMAP                  = 11,   ; sys_munmap()
    SYS_RT_SIGACTION            = 13,   ; sys_rt_sigaction()
    SYS_RT_SIGPROCMASK          = 14,   ; sys_rt_sigprocmask()
    SYS_RT_SIGRETURN            = 15,   ; stub_rt_sigreturn()
    SYS_IOCTL                   = 16,   ; sys_ioctl()
    SYS_PWRITE64                = 18,   ; sys_pwrite64()
    SYS_READV                   = 19,   ; sys_readv()
    SYS_WRITEV                  = 20,   ; sys_writev()
    SYS_ACCESS                  = 21,   ; sys_access()
    SYS_PIPE                    = 22,   ; sys_pipe()
    SYS_SELECT                  = 23,   ; sys_select()
    SYS_MREMAP                  = 25,   ; sys_mremap()
    SYS_MSYNC                   = 26,   ; sys_msync()
    SYS_SHMGET                  = 29,   ; sys_shmget()
    SYS_SHMAT                   = 30,   ; sys_shmat()
    SYS_SHMCTL                  = 31,   ; sys_shmctl()
    SYS_DUP2                    = 33,   ; sys_dup2()
    SYS_PAUSE                   = 34,   ; sys_pause()
    SYS_NANOSLEEP               = 35,   ; sys_nanosleep()
    SYS_GETITIMER               = 36,   ; sys_getitimer()
    SYS_ALARM                   = 37,   ; sys_alarm()
    SYS_SETITIMER               = 38,   ; sys_setitimer()
    SYS_GETPID                  = 39,   ; sys_getpid()
    SYS_SENDFILE                = 40,   ; sys_sendfile64()
    SYS_SOCKET                  = 41,   ; sys_socket()
    SYS_ACCEPT                  = 43,   ; sys_accept()
    SYS_SENDTO                  = 44,   ; sys_sendto()
    SYS_RECVFROM                = 45,   ; sys_recvfrom()
    SYS_SHUTDOWN                = 48,   ; sys_shutdown()
    SYS_BIND                    = 49,   ; sys_bind()
    SYS_LISTEN                  = 50,   ; sys_listen()
    SYS_SOCKETPAIR              = 53,   ; sys_socketpair()
    SYS_SETSOCKOPT              = 54,   ; sys_setsockopt()
    SYS_GETSOCKOPT              = 55,   ; sys_getsockopt()
    SYS_CLONE                   = 56,   ; stub_clone()
    SYS_FORK                    = 57,   ; stub_fork()
    SYS_VFORK                   = 58,   ; stub_vfork()
    SYS_EXECVE                  = 59,   ; stub_execve()
    SYS_EXIT                    = 60,   ; sys_exit()
    SYS_WAIT4                   = 61,   ; sys_wait4()
    SYS_KILL                    = 62,   ; sys_kill()
    SYS_UNAME                   = 63,   ; sys_newuname()
    SYS_SEMGET                  = 64,   ; sys_semget()
    SYS_SEMOP                   = 65,   ; sys_semop()
    SYS_SEMCTL                  = 66,   ; sys_semctl()
    SYS_SHMDT                   = 67,   ; sys_shmdt()
    SYS_MSGGET                  = 68,   ; sys_msgget()
    SYS_MSGSND                  = 69,   ; sys_msgsnd()
    SYS_MSGRCV                  = 70,   ; sys_msgrcv()
    SYS_MSGCTL                  = 71,   ; sys_msgctl()
    SYS_FCNTL                   = 72,   ; sys_fcntl()
    SYS_FLOCK                   = 73,   ; sys_flock()
    SYS_FSYNC                   = 74,   ; sys_fsync()
    SYS_FDATASYNC               = 75,   ; sys_fdatasync()
    SYS_TRUNCATE                = 76,   ; sys_truncate()
    SYS_FTRUNCATE               = 77,   ; sys_ftruncate()
    SYS_GETDENTS                = 78,   ; sys_getdents()
    SYS_GETCWD                  = 79,   ; sys_getcwd()
    SYS_CHDIR                   = 80,   ; sys_chdir()
    SYS_FCHDIR                  = 81,   ; sys_fchdir()
    SYS_RENAME                  = 82,   ; sys_rename()
    SYS_MKDIR                   = 83,   ; sys_mkdir()
    SYS_RMDIR                   = 84,   ; sys_rmdir()
    SYS_CREAT                   = 85,   ; sys_creat()
    SYS_LINK                    = 86,   ; sys_link()
    SYS_UNLINK                  = 87,   ; sys_unlink()
    SYS_READLINK                = 89,   ; sys_readlink()
    SYS_CHMOD                   = 90,   ; sys_chmod()
    SYS_FCHMOD                  = 91,   ; sys_fchmod()
    SYS_CHOWN                   = 92,   ; sys_chown()
    SYS_FCHOWN                  = 93,   ; sys_fchown()
    SYS_LCHOWN                  = 94,   ; sys_lchown()
    SYS_UMASK                   = 95,   ; sys_umask()
    SYS_GETTIMEOFDAY            = 96,   ; sys_gettimeofday()
    SYS_GETRLIMIT               = 97,   ; sys_getrlimit()
    SYS_GETRUSAGE               = 98,   ; sys_getrusage()
    SYS_TIMES                   = 100,  ; sys_times()
    SYS_PTRACE                  = 101,  ; sys_ptrace()
    SYS_GETUID                  = 102,  ; sys_getuid()
    SYS_SYSLOG                  = 103,  ; sys_syslog()
    SYS_GETGID                  = 104,  ; sys_getgid()
    SYS_SETUID                  = 105,  ; sys_setuid()
    SYS_SETGID                  = 106,  ; sys_setgid()
    SYS_SETSID                  = 112,  ; sys_setsid()
    SYS_SETREUID                = 113,  ; sys_setreuid()
    SYS_SETREGID                = 114,  ; sys_setregid()
    SYS_GETGROUPS               = 115,  ; sys_getgroups()
    SYS_SETGROUPS               = 116,  ; sys_setgroups()
    SYS_SETRESUID               = 117,  ; sys_setresuid()
    SYS_GETRESUID               = 118,  ; sys_getresuid()
    SYS_SETRESGID               = 119,  ; sys_setresgid()
    SYS_GETRESGID               = 120,  ; sys_getresgid()
    SYS_SETFSUID                = 122,  ; sys_setfsuid()
    SYS_SETFSGID                = 123,  ; sys_setfsgid()
    SYS_GETSID                  = 124,  ; sys_getsid()
    SYS_CAPGET                  = 125,  ; sys_capget()
    SYS_CAPSET                  = 126,  ; sys_capset()
    SYS_RT_SIGPENDING           = 127,  ; sys_rt_sigpending()
    SYS_RT_SIGSUSPEND           = 130,  ; sys_rt_sigsuspend()
    SYS_UTIME                   = 132,  ; sys_utime()
    SYS_MKNOD                   = 133,  ; sys_mknod()
    SYS_USELIB                  = 134,  ; sys_uselib()
    SYS_USTAT                   = 136,  ; sys_ustat()
    SYS_STATFS                  = 137,  ; sys_statfs()
    SYS_SYSFS                   = 139,  ; sys_sysfs()
    SYS_SCHED_SETPARAM          = 142,  ; sys_sched_setparam()
    SYS_SCHED_GETPARAM          = 143,  ; sys_sched_getparam()
    SYS_SCHED_SETSCHEDULER      = 144,  ; sys_sched_setscheduler()
    SYS_SCHED_GETSCHEDULER      = 145,  ; sys_sched_getscheduler()
    SYS_SCHED_GET_PRIORITY_MAX  = 146,  ; sys_sched_get_priority_max()
    SYS_SCHED_GET_PRIORITY_MIN  = 147,  ; sys_sched_get_priority_min()
    SYS_SCHED_RR_GET_INTERVAL   = 148,  ; sys_sched_rr_get_interval()
    SYS_MLOCK                   = 149,  ; sys_mlock()
    SYS_MLOCKALL                = 151,  ; sys_mlockall()
    SYS_MUNLOCKALL              = 152,  ; sys_munlockall()
    SYS_MODIFY_LDT              = 154,  ; sys_modify_ldt()
    SYS_PIVOT_ROOT              = 155,  ; sys_pivot_root()
    SYS_PRCTL                   = 157,  ; sys_prctl()
    SYS_ARCH_PRCTL              = 158,  ; sys_arch_prctl()
    SYS_ADJTIMEX                = 159,  ; sys_adjtimex()
    SYS_SETRLIMIT               = 160,  ; sys_setrlimit()
    SYS_CHROOT                  = 161,  ; sys_chroot()
    SYS_SYNC                    = 162,  ; sys_sync()
    SYS_ACCT                    = 163,  ; sys_acct()
    SYS_SETTIMEOFDAY            = 164,  ; sys_settimeofday()
    SYS_MOUNT                   = 165,  ; sys_mount()
    SYS_SWAPON                  = 167,  ; sys_swapon()
    SYS_REBOOT                  = 169,  ; sys_reboot()
    SYS_SETDOMAINNAME           = 171,  ; sys_setdomainname()
    SYS_IOPL                    = 172,  ; stub_iopl()
    SYS_IOPERM                  = 173,  ; sys_ioperm()
    SYS_CREATE_MODULE           = 174,  ;
    SYS_DELETE_MODULE           = 176,  ; sys_delete_module()
    SYS_GET_KERNEL_SYMS         = 177,  ;
    SYS_QUERY_MODULE            = 178,  ;
    SYS_QUOTACTL                = 179,  ; sys_quotactl()
    SYS_NFSSERVCTL              = 180,  ;
    SYS_GETPMSG                 = 181,  ;
    SYS_PUTPMSG                 = 182,  ;
    SYS_AFS_SYSCALL             = 183,  ;
    SYS_TUXCALL                 = 184,  ;
    SYS_SECURITY                = 185,  ;
    SYS_GETTID                  = 186,  ; sys_gettid()
    SYS_READAHEAD               = 187,  ; sys_readahead()
    SYS_SETXATTR                = 188,  ; sys_setxattr()
    SYS_LSETXATTR               = 189,  ; sys_lsetxattr()
    SYS_FSETXATTR               = 190,  ; sys_fsetxattr()
    SYS_GETXATTR                = 191,  ; sys_getxattr()
    SYS_LGETXATTR               = 192,  ; sys_lgetxattr()
    SYS_FGETXATTR               = 193,  ; sys_fgetxattr()
    SYS_LISTXATTR               = 194,  ; sys_listxattr()
    SYS_LLISTXATTR              = 195,  ; sys_llistxattr()
    SYS_FLISTXATTR              = 196,  ; sys_flistxattr()
    SYS_LREMOVEXATTR            = 198,  ; sys_lremovexattr()
    SYS_FREMOVEXATTR            = 199,  ; sys_fremovexattr()
    SYS_TKILL                   = 200,  ; sys_tkill()
    SYS_TIME                    = 201,  ; sys_time()
    SYS_FUTEX                   = 202,  ; sys_futex()
    SYS_SCHED_SETAFFINITY       = 203,  ; sys_sched_setaffinity()
    SYS_SCHED_GETAFFINITY       = 204,  ; sys_sched_getaffinity()
    SYS_SET_THREAD_AREA         = 205,  ;
    SYS_IO_SETUP                = 206,  ; sys_io_setup()
    SYS_IO_DESTROY              = 207,  ; sys_io_destroy()
    SYS_IO_GETEVENTS            = 208,  ; sys_io_getevents()
    SYS_IO_SUBMIT               = 209,  ; sys_io_submit()
    SYS_IO_CANCEL               = 210,  ; sys_io_cancel()
    SYS_GET_THREAD_AREA         = 211,  ;
    SYS_LOOKUP_DCOOKIE          = 212,  ; sys_lookup_dcookie()
    SYS_EPOLL_CREATE            = 213,  ; sys_epoll_create()
    SYS_EPOLL_CTL_OLD           = 214,  ;
    SYS_EPOLL_WAIT_OLD          = 215,  ;
    SYS_REMAP_FILE_PAGES        = 216,  ; sys_remap_file_pages()
    SYS_GETDENTS64              = 217,  ; sys_getdents64()
    SYS_SEMTIMEDOP              = 220,  ; sys_semtimedop()
    SYS_FADVISE64               = 221,  ; sys_fadvise64()
    SYS_TIMER_CREATE            = 222,  ; sys_timer_create()
    SYS_TIMER_SETTIME           = 223,  ; sys_timer_settime()
    SYS_TIMER_GETTIME           = 224,  ; sys_timer_gettime()
    SYS_TIMER_GETOVERRUN        = 225,  ; sys_timer_getoverrun()
    SYS_TIMER_DELETE            = 226,  ; sys_timer_delete()
    SYS_CLOCK_SETTIME           = 227,  ; sys_clock_settime()
    SYS_CLOCK_GETTIME           = 228,  ; sys_clock_gettime()
    SYS_CLOCK_GETRES            = 229,  ; sys_clock_getres()
    SYS_EXIT_GROUP              = 231,  ; sys_exit_group()
    SYS_EPOLL_WAIT              = 232,  ; sys_epoll_wait()
    SYS_EPOLL_CTL               = 233,  ; sys_epoll_ctl()
    SYS_TGKILL                  = 234,  ; sys_tgkill()
    SYS_UTIMES                  = 235,  ; sys_utimes()
    SYS_VSERVER                 = 236,  ;
    SYS_MBIND                   = 237,  ; sys_mbind()
    SYS_SET_MEMPOLICY           = 238,  ; sys_set_mempolicy()
    SYS_GET_MEMPOLICY           = 239,  ; sys_get_mempolicy()
    SYS_MQ_UNLINK               = 241,  ; sys_mq_unlink()
    SYS_MQ_TIMEDSEND            = 242,  ; sys_mq_timedsend()
    SYS_MQ_NOTIFY               = 244,  ; sys_mq_notify()
    SYS_MQ_GETSETATTR           = 245,  ; sys_mq_getsetattr()
    SYS_KEXEC_LOAD              = 246,  ; sys_kexec_load()
    SYS_WAITID                  = 247,  ; sys_waitid()
    SYS_KEYCTL                  = 250,  ; sys_keyctl()
    SYS_IOPRIO_SET              = 251,  ; sys_ioprio_set()
    SYS_IOPRIO_GET              = 252,  ; sys_ioprio_get()
    SYS_INOTIFY_INIT            = 253,  ; sys_inotify_init()
    SYS_INOTIFY_ADD_WATCH       = 254,  ; sys_inotify_add_watch()
    SYS_INOTIFY_RM_WATCH        = 255,  ; sys_inotify_rm_watch()
    SYS_MIGRATE_PAGES           = 256,  ; sys_migrate_pages()
    SYS_OPENAT                  = 257,  ; sys_openat()
    SYS_FCHOWNAT                = 260,  ; sys_fchownat()
    SYS_FUTIMESAT               = 261,  ; sys_futimesat()
    SYS_NEWFSTATAT              = 262,  ; sys_newfstatat()
    SYS_UNLINKAT                = 263,  ; sys_unlinkat()
    SYS_RENAMEAT                = 264,  ; sys_renameat()
    SYS_LINKAT                  = 265,  ; sys_linkat()
    SYS_SYMLINKAT               = 266,  ; sys_symlinkat()
    SYS_READLINKAT              = 267,  ; sys_readlinkat()
    SYS_FCHMODAT                = 268,  ; sys_fchmodat()
    SYS_FACCESSAT               = 269,  ; sys_faccessat()
    SYS_PSELECT6                = 270,  ; sys_pselect6()
    SYS_PPOLL                   = 271,  ; sys_ppoll()
    SYS_SPLICE                  = 275,  ; sys_splice()
    SYS_VMSPLICE                = 278,  ; sys_vmsplice()
    SYS_MOVE_PAGES              = 279,  ; sys_move_pages()
    SYS_UTIMENSAT               = 280,  ; sys_utimensat()
    SYS_SIGNALFD                = 282,  ; sys_signalfd()
    SYS_TIMERFD_CREATE          = 283,  ; sys_timerfd_create()
    SYS_FALLOCATE               = 285,  ; sys_fallocate()
    SYS_SIGNALFD4               = 289,  ; sys_signalfd4()
    SYS_EVENTFD2                = 290,  ; sys_eventfd2()
    SYS_EPOLL_CREATE1           = 291,  ; sys_epoll_create1()
    SYS_DUP3                    = 292,  ; sys_dup3()
    SYS_PIPE2                   = 293,  ; sys_pipe2()
    SYS_INOTIFY_INIT1           = 294,  ; sys_inotify_init1()
    SYS_PREADV                  = 295,  ; sys_preadv()
    SYS_RT_TGSIGQUEUEINFO       = 297,  ; sys_rt_tgsigqueueinfo()
    SYS_RECVMMSG                = 299,  ; sys_recvmmsg()
    SYS_FANOTIFY_INIT           = 300,  ; sys_fanotify_init()
    SYS_FANOTIFY_MARK           = 301,  ; sys_fanotify_mark()
    SYS_PRLIMIT64               = 302,  ; sys_prlimit64()
    SYS_NAME_TO_HANDLE_AT       = 303,  ; sys_name_to_handle_at()
    SYS_OPEN_BY_HANDLE_AT       = 304,  ; sys_open_by_handle_at()
    SYS_CLOCK_ADJTIME           = 305,  ; sys_clock_adjtime()
    SYS_SYNCFS                  = 306,  ; sys_syncfs()
    SYS_SENDMMSG                = 307,  ; sys_sendmmsg()
    SYS_SETNS                   = 308,  ; sys_setns()
    SYS_GETCPU                  = 309,  ; sys_getcpu()
    SYS_PROCESS_VM_READV        = 310,  ; sys_process_vm_readv()
    SYS_PROCESS_VM_WRITEV       = 311,  ; sys_process_vm_writev()
    SYS_KCMP                    = 312,  ; sys_kcmp()
    SYS_FINIT_MODULE            = 313,  ; sys_finit_module()
    }


define PROT_READ        0x01
define PROT_WRITE       0x02
define MAP_PRIVATE      0x02
define MAP_ANON         0x20
define MAP_ANONYMOUS    MAP_ANON
define MMAP_FLAGS       (MAP_PRIVATE or MAP_ANONYMOUS)
define MMAP_PROT        (PROT_READ or PROT_WRITE)
define MAP_FAILED       (-1)

sys_read proto :int_t, :ptr, :size_t {
    mov eax,SYS_READ
    syscall
    }
sys_write proto :int_t, :ptr, :size_t {
    mov eax,SYS_WRITE
    syscall
    }
sys_open proto :string_t, :int_t, :int_t {
    mov eax,SYS_OPEN
    syscall
    }
sys_creat proto :string_t, :uint_t {
    mov eax,SYS_CREAT
    syscall
    }
sys_close proto :int_t {
    mov eax,SYS_CLOSE
    syscall
    }
sys_lseek proto :int_t, :size_t, :uint_t {
    mov eax,SYS_LSEEK
    syscall
    }
sys_mmap proto syscall :ptr, :size_t, :size_t, :size_t, :size_t, :size_t {
    add rsi,_GRANULARITY-1
    and sil,-(_GRANULARITY)
    mov r10,rcx
    mov rcx,rsi
    mov eax,SYS_MMAP
    syscall
    }
sys_munmap proto syscall :ptr, :size_t {
    mov eax,SYS_MUNMAP
    syscall
    }
sys_access proto :string_t, :int_t {
    mov eax,SYS_ACCESS
    syscall
    }
sys_ioctl proto :int_t, :int_t, :ptr {
    mov eax,SYS_IOCTL
    syscall
    }
sys_getcwd proto :string_t, :int_t {
    mov eax,SYS_GETCWD
    syscall
    }
sys_chdir proto :string_t {
    mov eax,SYS_CHDIR
    syscall
    }
sys_chroot proto :string_t {
    mov eax,SYS_CHROOT
    syscall
    }
sys_fchdir proto :int_t {
    mov eax,SYS_FCHDIR
    syscall
    }
sys_mkdir proto :string_t {
    mov eax,SYS_MKDIR
    syscall
    }
sys_rmdir proto :string_t {
    mov eax,SYS_RMDIR
    syscall
    }
sys_exit proto :int_t {
    mov eax,SYS_EXIT
    syscall
    }
