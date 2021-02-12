//*****************************************************************************
//    # #              Name   : CamConfig.h
//  #     #            Date   : Jan. 22, 2021
// #    #  #  #     #  Author : Qiwei Wu
//  #     #  # #  # #  Version: 1.0
//    # #  #    #   #
// Camera configuration.
//*****************************************************************************

#ifndef __CAM_CONFIG_H__
#define __CAM_CONFIG_H__

//*****************************************************************************
// Includes
//*****************************************************************************
#include "BaseDef.h"

//*****************************************************************************
// Variables
//*****************************************************************************
struct RegInfo_t
{
   u16 reg;
   u8  val;
};

//*****************************************************************************
// Functions
//*****************************************************************************
int WriteRegArray(struct RegInfo_t *regArray);
int CamInit();

#endif
