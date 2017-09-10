//
//  ViewHelper.m
//  shpRead_ipad_02
//
//  Created by shy on 15/5/8.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import "ViewHelper.h"
#import "QCheckBox.h"
#import "MapRenderer.h"

@implementation ViewHelper

+(QCheckBox *)createCheckedButton:(double)x andY:(double)y andWidth:(double)width andHeight:(double)height andTitle:(NSString *)title andTag:(int)tag andChecked:(BOOL)checked andDelegate:(id<QCheckBoxDelegate>) delegate{

        QCheckBox *_check3 = [[QCheckBox alloc] initWithDelegate:delegate];
        _check3.frame = CGRectMake(x, y,width,height);
        [_check3 setTag:tag];
        
        [_check3 setContentMode:UIViewContentModeScaleToFill];
        
        [_check3 setTitle:title forState:UIControlStateNormal];
        [_check3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_check3 setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
        [_check3 setTitleColor:[MapRenderer getColor] forState:UIControlStateSelected];
        [_check3.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
        [_check3 setImage:[UIImage imageNamed:@"checkbox1_unchecked.png"] forState:UIControlStateNormal];
        [_check3 setImage:[UIImage imageNamed:@"checkbox1_checked.png"] forState:UIControlStateSelected];
        [_check3 setChecked:checked];
        [_check3 setHidden:NO];
    return _check3;
}

@end
