#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kmod.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("escapepod");
MODULE_DESCRIPTION("kernel monitoring module");

static int __init monitor_init(void) {
    char *argv[] = {
        "/bin/sh", "-c",
        "/scripts/start-monitor",
        NULL
    };
    char *envp[] = {
        "HOME=/", "PATH=/sbin:/bin:/usr/sbin:/usr/bin", NULL
    };
    printk(KERN_INFO "monitor: loading\n");
    call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
    return 0;
}

static void __exit monitor_exit(void) {
    printk(KERN_INFO "monitor: unloading\n");
}

module_init(monitor_init);
module_exit(monitor_exit);
