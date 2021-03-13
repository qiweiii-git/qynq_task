//*****************************************************************************
//    # #              Name   : upload.c
//  #     #            Date   : Feb. 19, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
//
// This module is the upload function of WEB server.
//
// Change History:
//  VER.   Author         DATE              Change Description
//  1.0    Qiwei Wu       Feb. 19, 2021     Initial Release
//*****************************************************************************

//*****************************************************************************
// Headers
//*****************************************************************************
#include <sys/mman.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <StrToInt.h>
#include <BaseDef.h>
#include <cgic.h>

//*****************************************************************************
// Defines
//*****************************************************************************
#define BufferLen 1024

//*****************************************************************************
// Main
//*****************************************************************************
int cgiMain(void)
{
   cgiFilePtr file;
   int targetFile;
   mode_t mode;
   char name[128];
   char fileNameOnServer[64];
   char contentType[1024];
   char buffer[BufferLen];
   char *tmpStr=NULL;
   int size;
   int got;

   // 输出HTML头部（声明文档类型）
   printf("Content-Type:text/html;\r\n\r\n");
   printf("<html><body>\r\n");

   // 取得html页面中file元素的值，应该是文件在客户机上的路径名
   if(cgiFormFileName("file", name, sizeof(name)) != cgiFormSuccess)
   {
      printf("could not get filename. \r\n");
      goto FAIL;
   }

   cgiFormFileSize("file", &size);

   // 取得文件类型
   cgiFormFileContentType("file", contentType, sizeof(contentType));

   // 打开文件
   if (cgiFormFileOpen("file", &file) != cgiFormSuccess)
   {
      printf("could not open the file. \r\n");
      goto FAIL;
   }

   // 判断文件是否是BMP图片
   if(strstr(name, ".bmp"))
   {
      strcpy(fileNameOnServer, "/mnt/user_bmp.bmp");
   }
   // 判断是否是升级文件
   if(strstr(name, "upgrade.tar.gz"))
   {
      strcpy(fileNameOnServer, "/tmp/upgrade.tar.gz");
   }
   else
   {
      goto FAIL;
   }

   mode = S_IRWXU|S_IRGRP|S_IROTH;

   // 在fileNameOnServer目录下建立新的文件
   targetFile = open(fileNameOnServer, O_RDWR|O_CREAT|O_TRUNC|O_APPEND, mode);
   if(targetFile < 0)
   {
      printf("could not create the file %s. \r\n", fileNameOnServer);
      goto FAIL;
   }

   // 从系统临时文件中读出文件内容，并放到刚创建的目标文件中
   while(cgiFormFileRead(file, buffer, BufferLen, &got) == cgiFormSuccess)
   {
      if(got > 0)
      write(targetFile, buffer, got);
   }

   cgiFormFileClose(file);
   close(targetFile);
   goto END;

   FAIL:
      printf("Failed to upload \r\n");
      printf("</body></html>");
      return 1;
   END:
      printf("File %s has been uploaded", fileNameOnServer);
      printf("</body></html>");
      return 0;
}
