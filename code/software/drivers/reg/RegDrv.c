//*****************************************************************************
//    # #              Name   : LedDriver.c
//  #     #            Date   : Dec. 25, 2020
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// The Reg contrl driver.
//*****************************************************************************

// include
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/init.h>
#include <linux/delay.h>
#include <asm/uaccess.h>
#include <asm/irq.h>
#include <asm/io.h>

// define
#define DEVICE_NAME "regctrl"

// variables
static struct class *regDrvClass;
static struct class_device	*regDrvClassDev;

volatile unsigned long *m_RegAddr = NULL;

// called from open(/dev/regctrl)
static int RegDrvOpen(struct inode *inode, struct file *file)
{
   printk(DEVICE_NAME " Open\n");
   return 0;
}

// called from write(/dev/regctrl)
static ssize_t RegDrvWrite(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
{
   unsigned int data;
   unsigned long *address;

   printk(DEVICE_NAME " Write\n");

   //copy_from_user(&data, buf, size);
   copy_from_user(&data, buf, 4);

   address = m_RegAddr + (size << 2);
   *address = data;

   return 0;
}

// called from read(/dev/regctrl)
static ssize_t RegDrvRead(struct file *file, const char __user *buf, size_t size, loff_t *ppos)
{
   unsigned int data;
   unsigned long *address;

   printk(DEVICE_NAME " Read\n");

   address = m_RegAddr + (size << 2);
   data = *address;

   copy_to_user(buf, &data, 4);

   return 0;
}

// file operations
static struct file_operations RegDrvFops =
{
   .owner = THIS_MODULE,
   .write = RegDrvWrite,
   .read  = RegDrvRead,
   .open  = RegDrvOpen,
};

// called from 'insmod RegDrv.ko'
static int __init RegDrvInit(void)
{
   int major;;
   /* 注册字符设备驱动程序
    * 参数为：主设备号，设备名字，file_operations结构
    * 主设备号可以为0，表示由内核自动分配主设备号
    */
   major = register_chrdev(232, DEVICE_NAME, &RegDrvFops);
   if(major < 0)
   {
      printk(DEVICE_NAME " Can not register major number\n");
      return major;
   }

   m_RegAddr = (volatile unsigned long *)ioremap(0x41000000, 0x2000);

   printk(DEVICE_NAME " initialized\n");
   return 0;
}

// called from 'rmmod RegDrv.ko'
static void __exit RegDrvrExit(void)
{
   // 卸载驱动程序
   unregister_chrdev(232, DEVICE_NAME);

   iounmap(m_RegAddr);
}

module_init(RegDrvInit);
module_exit(RegDrvrExit);
