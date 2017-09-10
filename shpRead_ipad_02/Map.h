//
//  Map.h
//  shpRead_ipad_02
//
//  Created by shy on 15/5/4.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QCheckBoxDelegate;
@interface Map : NSObject{
    @private
    
    @public
    //封装图层数据
    NSMutableArray *layerData;
    //
    NSMutableArray *layerDisplayButton;
}

-(void)createLayer:(long)count andDelegate:(id<QCheckBoxDelegate>) delegate;
-(void)displayLayers:(long)count andHidden:(BOOL)isHidden;
-(void)setLayerButtonAllChecked:(BOOL)checked;
-(void)updateLayerName:(long)index andName:(NSString *)name;
-(int)getShowingLayersCount;
-(UIColor *)getLayerRandomColor;

@end
