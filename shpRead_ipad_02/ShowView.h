//
//  ShowView.h
//  shpRead_ipad_02
//
//  Created by shy on 15/4/5.
//  Copyright (c) 2015年 SHY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Layer.h"
#import "Shapefile.h"
#import "ShapePoint.h"
#import "ShapePolyline.h"

#define TwoDInitScale 14
#define OPWorld 5000
#define OPChina 3500
#define MPChina 10000
#define MPWorld 20000

#define viewHalfWidth self.bounds.size.width/2
#define viewHalfHeight  self.bounds.size.height/2
@class MeasureUtil;
@class orthographic_projection_oc;
@class Mercator_projection;
@class Map;

@interface ShowView : UIView{
    
    CGContextRef myContext;
    CGPoint beginPoint;
    CGPoint endPoint;
    //保存图层
    
    id controller;

    BOOL isload;

    long m_nExtendWidth;
    long m_nExtendHeight;
    long m_nWidth;
    long m_nHeight;
    
    float zoom;

    //原点
    CGPoint startPoint;
    
@public
    //currentTap point
    CGPoint currentTap;
    
    //投影方式
    int projectionPattern;
    //地图类型
    int mapDispalyType;
    //当前原点位置
    CGPoint originPos;
    //当前的缩放比例
    double originScale;
    //开始点的点
    CGPoint toucheBeginPoint;
    CGPoint toucheEndPoint;
    //当前偏移量
    CGPoint offset;
    //绘制图形的倍数，此值是为了显示居中，有一个合适的倍数
    //坐标的放大倍数
    double coordinate_scale;

    //旋转角
    CGFloat angel;

    //map对象
    Map *map;
    
    //保存搜索图片
    CGImageRef cgImage;
    
    //保存第一个图层的边界
    double extendLeft;
    double extendBottom;
    double extendRight;
    double extendTop;

    MeasureUtil *util;
    BOOL isSearching;
    NSObject *searchResult;
    BOOL isMeasuring;
    BOOL recognizeHilightChecked;
    BOOL AttrDisplayChecked;
    
    //高亮的图层
    int recognizeHilightLayerIndex;
    //高亮的多边形或点的索引
    int recognizeHilightIndex;
    
    orthographic_projection_oc *orthographic_projection;
    Mercator_projection *mercator_projection;
    double pScale;
}


@property(nonatomic,readwrite)Shapefile* m_shapefile;
@property(readwrite)BOOL load;
@property (readwrite) CGPoint startPoint;
@property (readwrite) float zoom;

-(void)setShapefile:(Shapefile *)shapefile;
- (BOOL) updateViewSize:(double)x andHeight:(double)y;

-(void)drawShapePoint:(Shapefile *)shp andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index;
-(void)drawShapePolyline:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index;
-(void)drawShapePolylineOP:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index;
-(void)drawShapePolylineOM:(Shapefile *)shp andDbfFile:(Dbffile *)dbfFile andNeedsRecognizeHilight:(BOOL)flag andIndex:(int)index;
-(void)drawAttrDbfInfo:(Shapefile *)shp withDbf:(Dbffile *)dbf withIndex:(int)index;
-(void)drawDistanceLine:(CGPoint)begin andEndPoint:(CGPoint)end;
-(void)drawImage:(CGPoint)point andType:(int)type andCGContext:(CGContextRef)context;
-(BOOL)drawSearchResult:(NSObject *)searchResult andContext:(CGContextRef)context;
-(void)drawCircle:(CGPoint)point withColor:(UIColor *)color;

@end
