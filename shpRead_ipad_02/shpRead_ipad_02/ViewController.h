//
//  ViewController.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/5.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCheckBox.h"
@class ShapePoint;
@class ShapePolyline;
@class Shapefile;
@class Dbffile;
@class Shxfile;
@class ShowView;
@class SettingView;
@class Map;
@class Layer;

#define LAYERNUM 10


@interface ViewController : UIViewController <QCheckBoxDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>{

    @public

    //ShowView对象
    IBOutlet ShowView *showView;
    IBOutlet SettingView *setingView;
    IBOutlet UISwitch *measureSwitch;
    IBOutlet UIButton *projectionPattern;
    IBOutlet UIButton *projectionCenter;
    IBOutlet UIButton *open;
    IBOutlet UIButton *clear;
    IBOutlet UIButton *search;
    IBOutlet UILabel *searchResultDisplay;
    IBOutlet UILabel *showlayersCountLabel;
    IBOutlet UILabel *location;
    IBOutlet UILabel *position;
    IBOutlet UILabel *distanceLabel;
    
    //UIAlertView
    UIAlertView *searchAlertView;
    
    //
    Map *map;
  
    int scale;
    double xmin,xmax,ymin,ymax;
    int n_1,n_2;
}

-(UIColor *)infoBlueColor;

-(IBAction)openClick:(id)sender;
-(IBAction)resetClick:(id)sender;
-(IBAction)search:(id)sender;
-(IBAction)clearClick:(id)sender;
-(IBAction)exitClick:(id)sender;

-(Shapefile *)openShapefile:(NSString *)strShapefile;
-(Dbffile *)openDbffile:(NSString *)strDbffile;
-(Shxfile *)openShxfile:(NSString *)strShxfile;

//边界
@property (readwrite) long extendLeft;
@property (readwrite) long extendBottom;

//依据中文搜索得到图层缩影信息
-(BOOL)getIndex:(Layer *)_layer andLayerInnerIndex:(int *)innerIndex andColumeIndex:(int)columeIndex andSearchCondition:(NSString *)searchStr;
-(NSString *)getAttrInfoByLayer:(Layer *)layer withLayerIndex:(int)layerIndex withAttrIndex:(int)index withLon:(double)lon andLat:(double)lat andOutputPolygonIndex:(int *)indexInfo;
-(int)getIndexInfoByLayer:(Layer *)layer withLon:(double)lon andLat:(double)lat;
-(BOOL)cantainsPoint:(ShapePoint *)point andLon:(double)ALon andLat:(double)ALat;
-(BOOL)cantains:(ShapePolyline *)polyline andLon:(double)ALon andLat:(double)ALat;

@end

