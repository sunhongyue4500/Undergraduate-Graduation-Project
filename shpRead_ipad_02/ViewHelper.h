//
//  ViewHelper.h
//  shpRead_ipad_02
//
//  Created by shy on 15/5/8.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCheckBox;
@protocol QCheckBoxDelegate;

enum{
    ImageTypeUnLoc = 1,
    ImageTypeUnSearch = 2
};

typedef NSUInteger ImageType;


//文字还是图片类型（经纬度转换为XY）
enum{
    LocImageType = 1,
    LocCharacterType = 2
};



@interface ViewHelper : NSObject

+(QCheckBox *)createCheckedButton:(double)x andY:(double)y andWidth:(double)width andHeight:(double)height andTitle:(NSString *)title andTag:(int)tag andChecked:(BOOL)checked andDelegate:(id<QCheckBoxDelegate>) delegate;

@end
