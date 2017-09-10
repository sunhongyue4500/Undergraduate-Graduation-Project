//
//  Layer.h
//  shpRead_ipad_02
//
//

//  Created by shy on 15/4/5.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Shapefile;
@class Shxfile;
@class Dbffile;

@interface Layer : NSObject{
    @private
    
    @public
    Shapefile *shpsLayer;
    Shxfile *shxLayer;
    Dbffile *dbfLayer;
    //绘制图层flag
    BOOL isShow;
    
}

@end
