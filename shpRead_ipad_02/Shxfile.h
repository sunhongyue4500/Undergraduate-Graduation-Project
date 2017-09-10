//
//  Shxfile.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/12.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shxfile : NSObject{

    @private
    
    @protected
    
    @public
    NSString *shxFilePath;
    int filecode;
    int fileLength;
    int fileVersion;
    int shpType;
    
    //上下左右边界
    double extendLeft;
    double extendTop;
    double extendRight;
    double extendBottom;
    
    //记录的条数
    long recordCount;
    
    //offset
    NSMutableArray *offset;
    //content length
    NSMutableArray *contentLength;
    


}

-(BOOL)loadShxfile:(NSString *)strShxfile;

@end
